import 'dart:async'; // <-- 1. Add this import for the Timer
import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _message = 'Search for products...';
  Timer? _debounce; // <-- 2. Add a Timer variable

  @override
  void dispose() {
    _debounce?.cancel(); // <-- 3. Cancel the timer when the screen is closed
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _message = 'Search for products...';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final results = await context.read<AuthService>().searchProducts(query);

    if(mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (_searchResults.isEmpty) {
          _message = 'No products found for "$query"';
        }
      });
    }
  }

  // 4. Create the debounce function
  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter product name...',
            border: InputBorder.none,
          ),
          // 5. Call the debounce function here
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
          ? Center(child: Text(_message, style: const TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final product = _searchResults[index];
          final imageUrl = product['thumbnail_url'];
          return ListTile(
            leading: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : Image.asset('assets/images/placeholder.png', width: 50, height: 50),
            title: Text(product['name']),
            subtitle: Text('\$${product['regular_price']}'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productSlug: product['slug'])
              ));
            },
          );
        },
      ),
    );
  }
}