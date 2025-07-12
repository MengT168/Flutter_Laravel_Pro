import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'home_screen.dart'; // Re-using the ProductCard for related products

class ProductDetailScreen extends StatefulWidget {
  final String productSlug;
  const ProductDetailScreen({super.key, required this.productSlug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _productData;
  bool _isLoading = true;

  // State for selections
  final List<int> _selectedSizeIds = [];
  final List<int> _selectedColorIds = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _authService.getProductDetail(widget.productSlug);
    if (mounted && data != null) {
      setState(() {
        _productData = data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _productData?['product']?['name'] ?? 'Product Detail'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productData == null
          ? const Center(child: Text('Product not found.'))
          : _buildProductDetailView(),
    );
  }

  Widget _buildProductDetailView() {
    final product = _productData!['product'];
    final relatedProducts = _productData!['related_products'] as List<dynamic>;
    final attributes = product['attributes'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          if (product['thumbnail_url'] != null)
            Image.network(
              product['thumbnail_url'],
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Image.asset('assets/images/default-image.jpg', fit: BoxFit.cover, height: 300),
            )
          else
            Image.asset('assets/images/default-image.jpg', fit: BoxFit.cover, height: 300),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(product['name'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Price
                _buildPriceWidget(product),
                const SizedBox(height: 24),

                // Attribute Selectors for Size and Color
                if (attributes['Size'] != null)
                  _buildAttributeSelector('Size', attributes['Size'], _selectedSizeIds),
                if (attributes['Color'] != null)
                  _buildAttributeSelector('Color', attributes['Color'], _selectedColorIds),

                const SizedBox(height: 16),

                // Quantity Selector
                _buildQuantitySelector(),
                const SizedBox(height: 24),

                // Description
                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(product['description'] ?? 'No description available.', style: const TextStyle(color: Colors.black54, height: 1.5)),

                const SizedBox(height: 24),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(onPressed: () {}, child: const Text('Add to Cart')),
                ),

                const SizedBox(height: 32),
                const Text('Related Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Related Products Carousel
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12),
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: relatedProducts[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Reusable widget for Size/Color attribute chips that allows multiple selections.
  Widget _buildAttributeSelector(String title, List<dynamic> options, List<int> selectedIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final bool isSelected = selectedIds.contains(option['id']);
            return FilterChip(
              label: Text(option['value']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedIds.add(option['id']);
                  } else {
                    selectedIds.remove(option['id']);
                  }
                });
              },
              selectedColor: Colors.black,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Helper widget for quantity selection.
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
          onPressed: () {
            if (_quantity > 1) {
              setState(() => _quantity--);
            }
          },
        ),
        Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.black),
          onPressed: () {
            setState(() => _quantity++);
          },
        ),
      ],
    );
  }

  /// Reusable price widget with the correct sale/regular price logic.
  Widget _buildPriceWidget(Map<String, dynamic> product) {
    final double salePrice = (product['sale_price'] as num?)?.toDouble() ?? 0.0;
    final double regularPrice = (product['regular_price'] as num?)?.toDouble() ?? 0.0;

    if (salePrice > 0 && salePrice < regularPrice) {
      // On sale
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '\$${salePrice.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(width: 10),
          Text(
            '\$${regularPrice.toStringAsFixed(2)}',
            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 16),
          ),
        ],
      );
    } else {
      // Not on sale
      return Text(
        '\$${regularPrice.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      );
    }
  }
}