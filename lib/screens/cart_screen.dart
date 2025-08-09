import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/checkout_screen.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

import '../l10n/app_localizations.dart'; // <-- Add this import

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _cartData;
  bool _isLoading = false;
  int? _updatingItemId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = context.watch<AuthService>();
    if (authService.user != null && _cartData == null && !_isLoading) {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
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

  void _removeItem(int cartItemId) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.removeItem),
        content: Text(localizations.removeItemConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(localizations.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.remove, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<AuthService>().removeCartItem(cartItemId);
      final message = success ? localizations.itemRemovedSuccess : localizations.itemRemovedFail;
      _showSnackbar(message, success);
      if (success) {
        _fetchCartItems();
      }
    }
  }

  void _updateQuantity(int cartItemId, bool increase) async {
    setState(() => _updatingItemId = cartItemId);
    final authService = context.read<AuthService>();
    final success = increase
        ? await authService.increaseCartItemQuantity(cartItemId)
        : await authService.decreaseCartItemQuantity(cartItemId);

    if (!success && mounted) {
      _showSnackbar(AppLocalizations.of(context)!.failedToUpdateQty, false);
      // We call fetchItems to get the correct server quantity on failure
      _fetchCartItems();
    }
    if(mounted) setState(() => _updatingItemId = null);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final localizations = AppLocalizations.of(context)!;

    if (authService.user != null && _cartData == null && !_isLoading) {
      _fetchCartItems();
    }
    if (authService.user == null && _cartData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) setState(() => _cartData = null);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myCart),
        elevation: 1,
      ),
      body: _buildBody(authService, localizations),
    );
  }

  Widget _buildBody(AuthService authService, AppLocalizations localizations) {
    if (authService.user == null) {
      return _buildLoginPrompt(context, localizations);
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cartData == null || (_cartData!['items'] as List).isEmpty) {
      return _buildEmptyCart(context, localizations);
    }
    return _buildCartView(_cartData!, localizations);
  }

  Widget _buildCartView(Map<String, dynamic> cartData, AppLocalizations localizations) {
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
                return _CartItemCard(item: items[index], localizations: localizations);
              },
            ),
          ),
        ),
        _buildSummaryCard(totalAmount.toDouble(), localizations),
      ],
    );
  }

  Widget _CartItemCard({required Map<String, dynamic> item, required AppLocalizations localizations}) {
    final imageUrl = item['thumbnail_url'];
    final bool isUpdating = _updatingItemId == item['cart_item_id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                  : Image.asset('assets/images/placeholder.png', width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['product_name'] ?? 'No Name', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('\$${item['price']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                  TextButton(
                    onPressed: () => _removeItem(item['cart_item_id']),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, foregroundColor: Theme.of(context).colorScheme.error),
                    child: Text(localizations.remove, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            isUpdating
                ? const SizedBox(width: 96, child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                : Row(
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22), onPressed: item['quantity'] > 1 ? () => _updateQuantity(item['cart_item_id'], false) : null),
                Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.add_circle_outline, size: 22), onPressed: () => _updateQuantity(item['cart_item_id'], true)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, AppLocalizations localizations) {
    const double shipping = 5.00;
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(context, localizations.subtotal, '\$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(context, localizations.shipping, '\$${shipping.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(context, localizations.total, '\$${(total + shipping).toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Text(localizations.proceedToCheckout, style: const TextStyle(fontSize: 16)),
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

  Widget _buildEmptyCart(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.production_quantity_limits, size: 100, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(localizations.cartIsEmpty, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(localizations.cartIsEmptyMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(localizations.loginToViewCart, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isPoppingOnSuccess: true))),
            child: Text(localizations.loginOrRegister),
          ),
        ],
      ),
    );
  }
}
