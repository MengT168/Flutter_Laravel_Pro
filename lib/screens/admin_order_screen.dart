import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await context.read<AuthService>().getListOrder();
    if (mounted) {
      setState(() {
        _orderData = data;
        _isLoading = false;
      });
    }
  }

  void _acceptOrder(int id) async {
    final success = await context.read<AuthService>().acceptOrder(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order accepted ${success ? 'successfully' : 'failed'}'),
      ));
    }
    if (success) _fetchOrders();
  }

  void _rejectOrder(int id) async {
    final success = await context.read<AuthService>().rejectOrder(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order rejected ${success ? 'successfully' : 'failed'}'),
      ));
    }
    if (success) _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: (_orderData?['data'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            final order = (_orderData!['data'] as List)[index];
            final bool isPending = order['status'] == 'pending';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order['transaction_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('User: ${order['fullname']} (${order['phone']})'),
                    Text('Address: ${order['address']}'),
                    Text('Total: \$${order['total_amount']}'),
                    Text('Status: ${order['status']}'),
                    if(isPending)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => _rejectOrder(order['id']), child: const Text('Reject', style: TextStyle(color: Colors.red))),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: () => _acceptOrder(order['id']), child: const Text('Accept')),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}