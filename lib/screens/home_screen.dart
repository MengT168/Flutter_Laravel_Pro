import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart'; // Ensure this path is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _userName = '';
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ... (Your existing _loadData function remains unchanged)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user != null && user['name'] != null) {
        _userName = user['name'];
      } else {
        _userName = 'User';
      }
      _products = await _authService.getUsers();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ** THE SCAFFOLD HAS BEEN REMOVED FROM HERE **
    // The body of the screen is now returned directly.
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildPromoBanner(),
            const SizedBox(height: 20),
            _buildCategoryFilters(),
            const SizedBox(height: 24),
            _buildSectionHeader("Popular", () {}),
            const SizedBox(height: 12),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  // All your _build... helper widgets remain exactly the same
  // ... (_buildTopBar, _buildSearchBar, etc.) ...
  Widget _buildTopBar() {
    // ... same code ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hi, $_userName',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, size: 28, color: Colors.grey),
          tooltip: 'Logout',
          onPressed: () async {
            await _authService.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    // ... same code ...
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for shoes, clothes...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    // ... same code ...
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: NetworkImage('https://img.freepik.com/free-psd/special-sale-banner-template_23-2148975925.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    // ... same code ...
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _categoryChip("All", isSelected: true),
          _categoryChip("Shoes"),
          _categoryChip("Apparel"),
          _categoryChip("Bags"),
          _categoryChip("Electronics"),
        ],
      ),
    );
  }

  Widget _categoryChip(String title, {bool isSelected = false}) {
    // ... same code ...
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(color: isSelected ? Colors.blue.shade800 : Colors.black),
        shape: const StadiumBorder(),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    // ... same code ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    // ... same code ...
    return SizedBox(
      height: 260,
      child: _products.isEmpty
          ? const Center(child: Text('No products found.'))
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            imageUrl: 'https://i.pravatar.cc/150?u=${product['email']}',
            name: product['name'] ?? 'No Name',
            price: ((product['id'] ?? 0) * 3.14 + 15).toStringAsFixed(2),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  // ... same code ...
  final String imageUrl;
  final String name;
  final String price;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$$price',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black,
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 15),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}