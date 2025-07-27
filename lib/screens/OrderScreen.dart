import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if(confirmed == true) {
      final success = await context.read<AuthService>().cancelOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order cancellation ${success ? 'successful' : 'failed'}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
      if (success) _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // THE FIX: Always return a Scaffold as the main widget.
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      // Only the body will change based on the login state.
      body: authService.user == null
          ? _buildLoginPrompt()
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderList(),
    );
  }

  /// A widget to show when the user is not logged in.
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Login to see your order history.", style: TextStyle(fontSize: 16, color: Colors.grey)),
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

  /// A widget to show the list of orders.
  Widget _buildOrderList() {
    if (_orders.isEmpty) {
      return const Center(child: Text('You have no orders yet.'));
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
                      Text('Order #${order['transaction_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text(order['status'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: isPending ? Colors.orange : (order['status'] == 'cancel' ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Recipient: ${order['fullname']}'),
                  Text('Phone: ${order['phone']}'),
                  Text('Address: ${order['address']}'),
                  Text('Total: \$${order['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date: ${order['created_at']}'), // You might want to format this date
                  if (isPending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(order['id']),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Cancel Order'),
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