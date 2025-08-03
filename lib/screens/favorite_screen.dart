import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/home_screen.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final favorites = authService.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: user == null
          ? Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isPoppingOnSuccess: true))),
          child: const Text('Login to View Favorites'),
        ),
      )
          : favorites.isEmpty
          ? const Center(child: Text('You have no favorite items yet.'))
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ProductCard(product: favorites[index]);
        },
      ),
    );
  }
}