import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/product_detail_screen.dart';
import 'package:lara_flutter_pro/screens/search_screen.dart';
import '../auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Map<String, List<dynamic>> _products = {
    'new_products': [],
    'promotion_products': [],
    'popular_products': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _authService.getHomeData();
    if (data != null && mounted) {
      setState(() {
        _products['new_products'] = data['new_products'] ?? [];
        _products['promotion_products'] = data['promotion_products'] ?? [];
        _products['popular_products'] = data['popular_products'] ?? [];
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
        title: const Text('My Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to the new SearchScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchHomeData,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('New Arrivals'),
            _buildProductCarousel(_products['new_products'] ?? []),
            const SizedBox(height: 16),
            _buildSectionHeader('Promotions'),
            _buildProductCarousel(_products['promotion_products'] ?? []),
            const SizedBox(height: 16),
            _buildSectionHeader('Popular Products'),
            _buildProductCarousel(_products['popular_products'] ?? []),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {}, child: const Text('See All')),
        ],
      ),
    );
  }

  Widget _buildProductCarousel(List<dynamic> products) {
    if (products.isEmpty) {
      return const SizedBox(height: 240, child: Center(child: Text('No products found.')));
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}

/// A reusable widget for displaying a single, clickable product card.
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['thumbnail_url'];

    final double salePrice = (product['sale_price'] as num?)?.toDouble() ?? 0.0;
    final double regularPrice = (product['regular_price'] as num?)?.toDouble() ?? 0.0;

    Widget priceWidget;

    if (salePrice > 0 && salePrice < regularPrice) {
      priceWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '\$${salePrice.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${regularPrice.toStringAsFixed(2)}',
            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
          ),
        ],
      );
    } else {
      priceWidget = Text(
        '\$${regularPrice.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productSlug: product['slug']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.asset('assets/images/default-image.jpg', fit: BoxFit.cover),
                  loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                )
                    : Image.asset('assets/images/default-image.jpg', fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['name'] ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      priceWidget,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}