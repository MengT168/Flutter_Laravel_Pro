import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/product_detail_screen.dart';
import 'package:lara_flutter_pro/screens/search_screen.dart';
import 'package:lara_flutter_pro/screens/favorite_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final data = await context.read<AuthService>().getHomeData();
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
    final authService = context.watch<AuthService>();
    final localizations = AppLocalizations.of(context)!; // Helper for easier access

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myShop), // <-- TRANSLATED
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              if (authService.user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isPoppingOnSuccess: true)));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteScreen()));
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchHomeData,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(localizations.newArrivals), // <-- TRANSLATED
            _buildProductCarousel(_products['new_products'] ?? []),
            const SizedBox(height: 16),
            _buildSectionHeader(localizations.promotions), // <-- TRANSLATED
            _buildProductCarousel(_products['promotion_products'] ?? []),
            const SizedBox(height: 16),
            _buildSectionHeader(localizations.popularProducts), // <-- TRANSLATED
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
          TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.seeAll)), // <-- TRANSLATED
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
    // Watch the AuthService to get the latest list of favorites
    final authService = context.watch<AuthService>();
    final isFavorite = authService.favoriteProductIds.contains(product['id']);

    final imageUrl = product['thumbnail_url'];
    final double salePrice = (product['sale_price'] as num?)?.toDouble() ?? 0.0;
    final double regularPrice = (product['regular_price'] as num?)?.toDouble() ?? 0.0;

    Widget priceWidget;
    if (salePrice > 0 && salePrice < regularPrice) {
      priceWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('\$${salePrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Text('\$${regularPrice.toStringAsFixed(2)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
        ],
      );
    } else {
      priceWidget = Text('\$${regularPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(productSlug: product['slug'])),
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
                // THE CHANGE IS HERE: We use a Stack to overlay the favorite button
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                      loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator()),
                    )
                        : Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),

                    // The Favorite Button
                    if (authService.user != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              context.read<AuthService>().toggleFavorite(product['id']);
                            },
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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