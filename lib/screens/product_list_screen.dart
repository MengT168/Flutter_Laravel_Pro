import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/add_edit_product_screen.dart';
import '../auth/auth_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final products = await _authService.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  void _deleteProduct(int id) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product?'),
          content: const Text('This will permanently delete the product.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        )
    );

    if (confirmed == true) {
      final success = await _authService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product deleted ${success ? 'successfully' : 'failed'}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // For vertical scrolling
        child: SingleChildScrollView( // For horizontal scrolling
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _products.map((product) {
              final imageUrl = product['thumbnail_url'];

              return DataRow(cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    // This logic checks if the URL is valid, otherwise it shows the default asset image
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Image.asset('assets/images/default-image.jpg', width: 50, height: 50),
                    )
                        : Image.asset('assets/images/placeholder.png', width: 50, height: 50),
                  ),
                ),
                // Name Cell
                DataCell(Text(product['name'] ?? 'No Name')),
                // Price Cell
                DataCell(Text('\$${product['sale_price']}')),
                // Quantity Cell
                DataCell(Text(product['quantity'].toString())),
                // Actions Cell
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)))
                              .then((_) => _fetchProducts());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()))
              .then((_) => _fetchProducts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}