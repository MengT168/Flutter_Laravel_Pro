import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/checkout_screen.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _cartData;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is triggered when the widget is first built and when the user logs in.
    final authService = context.watch<AuthService>();
    if (authService.user != null && _cartData == null) {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    // We use context.read here because it's in a function, not the build method.
    final authService = context.read<AuthService>();
    if (authService.user == null) return;

    if (mounted) setState(() => _isLoading = true);
    final data = await authService.getCartItems();
    if (mounted) {
      setState(() {
        _cartData = data;
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

  /// Handles deleting an item from the cart after confirmation.
  void _removeItem(int cartItemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item?'),
        content: const Text('Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<AuthService>().removeCartItem(cartItemId);
      _showSnackbar('Item removed ${success ? 'successfully' : 'failed'}', success);
      if (success) {
        _fetchCartItems(); // Refresh the cart list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This line "watches" AuthService. When user logs in/out, this screen will rebuild.
    final authService = context.watch<AuthService>();

    // If the user logs in, authService.user will no longer be null, triggering a rebuild
    // and this condition will fetch the cart.
    if (authService.user != null && _cartData == null && !_isLoading) {
      _fetchCartItems();
    }
    // If a user logs out, we clear the old cart data.
    if (authService.user == null && _cartData != null) {
      // Use a post-frame callback to avoid calling setState during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _cartData = null;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: _buildBody(authService),
    );
  }

  Widget _buildBody(AuthService authService) {
    if (authService.user == null) {
      return _buildLoginPrompt(context);
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cartData == null || (_cartData!['items'] as List).isEmpty) {
      return _buildEmptyCart();
    }
    return _buildCartView();
  }

  /// The main view when the cart has items.
  Widget _buildCartView() {
    final items = _cartData!['items'] as List;
    final totalAmount = _cartData!['total_amount'] as num? ?? 0.0;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchCartItems,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _CartItemCard(item: items[index]);
              },
            ),
          ),
        ),
        _buildSummaryCard(totalAmount.toDouble()),
      ],
    );
  }

  Widget _CartItemCard({required Map<String, dynamic> item}) {
    final imageUrl = item['thumbnail_url'];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.asset('assets/images/default-image.jpg', width: 80, height: 80, fit: BoxFit.cover)
                  : Image.asset('assets/images/default-image.jpg', width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('\$${item['price']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                  TextButton(
                    onPressed: () => _removeItem(item['cart_item_id']),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, foregroundColor: Colors.red),
                    child: const Text('Remove', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey), onPressed: () {/* TODO: Implement decrease qty API call */} ),
                Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.add_circle_outline, size: 22), onPressed: () {/* TODO: Implement increase qty API call */} ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    const double shipping = 5.00; // Example shipping fee
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', '\$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow('Total', '\$${(total + shipping).toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? Colors.black : Colors.grey.shade700,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.production_quantity_limits, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Your Cart is Empty', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Looks like you haven\'t added\nanything to your cart yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Login to see your cart items.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isPoppingOnSuccess: true)));
            },
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }
}