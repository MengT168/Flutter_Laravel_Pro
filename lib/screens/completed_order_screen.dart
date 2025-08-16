import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class CompletedOrderScreen extends StatefulWidget {
  const CompletedOrderScreen({super.key});

  @override
  State<CompletedOrderScreen> createState() => _CompletedOrderScreenState();
}

class _CompletedOrderScreenState extends State<CompletedOrderScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompletedOrders();
  }

  Future<void> _fetchCompletedOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await context.read<AuthService>().getCompletedOrders();
    if (mounted && data != null) {
      setState(() {
        _orders = data['data'] as List<dynamic>;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchCompletedOrders,
        child: _orders.isEmpty
            ? const Center(child: Text('No completed orders found.'))
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order['transaction_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('User: ${order['fullname']}'),
                    Text('Total: \$${order['total_amount']}'),
                    Text('Date: ${order['updated_at']}'),
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