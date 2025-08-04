import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = context.watch<AuthService>();
    if (authService.user != null &&
        authService.cartData == null &&
        !_isLoading) {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    final authService = context.read<AuthService>();
    if (authService.user == null) return;

    if (mounted) setState(() => _isLoading = true);
    await authService.getCartItems();
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackbar(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

  void _removeItem(int cartItemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item?'),
        content: const Text(
            'Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
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
        _fetchCartItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 1,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
    if (authService.cartData == null ||
        (authService.cartData!['items'] as List).isEmpty) {
      return _buildEmptyCart();
    }
    return _buildCartView(authService.cartData!);
  }

  Widget _buildCartView(Map<String, dynamic> cartData) {
    final items = cartData['items'] as List;
    final totalAmount = cartData['total_amount'] as num? ?? 0.0;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchCartItems,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _CartItemCard(
                  item: items[index],
                  onRemove: _removeItem,
                  onQuantityChange: (cartItemId, increase) {
                    _updateQuantity(items[index], increase);
                  },
                );
              },
            ),
          ),
        ),
        _buildSummaryCard(totalAmount.toDouble()),
      ],
    );
  }

  void _updateQuantity(Map<String, dynamic> item, bool increase) {
    final oldQty = item['quantity'];
    setState(() => item['quantity'] = increase ? oldQty + 1 : oldQty - 1);

    final authService = context.read<AuthService>();
    final Future<bool> future = increase
        ? authService.increaseCartItemQuantity(item['cart_item_id'])
        : authService.decreaseCartItemQuantity(item['cart_item_id']);

    future.then((success) {
      if (!success) {
        setState(() => item['quantity'] = oldQty); // Rollback
        _showSnackbar('Failed to update quantity', false);
      }
    });
  }

  Widget _CartItemCard({
    required Map<String, dynamic> item,
    required Function(int) onRemove,
    required Function(int, bool) onQuantityChange,
  }) {
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
                  ? Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Image.asset(
                    'assets/images/default-image.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover),
              )
                  : Image.asset('assets/images/default-image.jpg',
                  width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? 'No Name',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('\$${item['price']}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14)),
                  TextButton(
                    onPressed: () => onRemove(item['cart_item_id']),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.red),
                    child: const Text('Remove', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon:  Icon(Icons.remove_circle_outline,
                      size: 22, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                  onPressed: item['quantity'] > 1
                      ? () => onQuantityChange(item['cart_item_id'], false)
                      : null,
                ),
                Text('${item['quantity']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () => onQuantityChange(item['cart_item_id'], true),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    const double shipping = 5.00;
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            _buildSummaryRow(context, 'Subtotal', '\$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Shipping', '\$${shipping.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(context, 'Total', '\$${(total + shipping).toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),

                child: const Text('Proceed to Checkout',
                    style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Icon(Icons.production_quantity_limits,
              size: 100, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Your Cart is Empty',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
           Text('Looks like you haven\'t added\nanything to your cart yet.',
              textAlign: TextAlign.center,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.shopping_cart_outlined,
              size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
           Text("Login to see your cart items.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const LoginScreen(isPoppingOnSuccess: true)));
            },
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }
}
