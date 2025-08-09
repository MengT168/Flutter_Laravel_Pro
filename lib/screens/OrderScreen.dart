import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

import '../l10n/app_localizations.dart'; // <-- Add this import

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = context.watch<AuthService>();
    if (authService.user != null) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    if (mounted) setState(() => _isLoading = true);
    final orders = await context.read<AuthService>().getMyOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  void _cancelOrder(int orderId) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.cancelOrder), // <-- TRANSLATED
        content: Text(localizations.cancelOrderConfirm), // <-- TRANSLATED
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(localizations.no)), // <-- TRANSLATED
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(localizations.yesCancel, style: const TextStyle(color: Colors.red))), // <-- TRANSLATED
        ],
      ),
    );

    if(confirmed == true) {
      final success = await context.read<AuthService>().cancelOrder(orderId);
      if (mounted) {
        final message = success ? localizations.orderCancellationSuccess : localizations.orderCancellationFail; // <-- TRANSLATED
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
      if (success) _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.myOrders)), // <-- TRANSLATED
      body: authService.user == null
          ? _buildLoginPrompt(localizations)
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderList(localizations),
    );
  }

  Widget _buildLoginPrompt(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(localizations.loginToViewOrders, style: const TextStyle(fontSize: 16, color: Colors.grey)), // <-- TRANSLATED
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isPoppingOnSuccess: true)));
            },
            child: Text(AppLocalizations.of(context)!.loginOrRegister), // <-- TRANSLATED
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(AppLocalizations localizations) {
    if (_orders.isEmpty) {
      return Center(child: Text(localizations.youHaveNoOrders)); // <-- TRANSLATED
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final isPending = order['status'] == 'pending';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(localizations.orderNumber(order['transaction_id'].toString()), style: const TextStyle(fontWeight: FontWeight.bold)), // <-- TRANSLATED
                      Chip(
                        label: Text(order['status'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: isPending ? Colors.orange : (order['status'] == 'cancel' ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(localizations.recipient(order['fullname'] ?? '')), // <-- TRANSLATED
                  Text(localizations.phone(order['phone'] ?? '')), // <-- TRANSLATED
                  Text(localizations.address(order['address'] ?? '')), // <-- TRANSLATED
                  Text('${localizations.total}: \$${order['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)), // <-- TRANSLATED
                  Text(localizations.date(order['created_at'] ?? '')), // <-- TRANSLATED
                  if (isPending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(order['id']),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(localizations.cancelOrder), // <-- TRANSLATED
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}