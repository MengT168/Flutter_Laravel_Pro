import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(isPoppingOnSuccess: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This line "watches" AuthService for changes and rebuilds the screen automatically
    final authService = context.watch<AuthService>();
    final user = authService.user; // Get the current user state

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // Only show the logout button if the user is logged in
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                // Call logout directly from the provider
                // We use context.read because we are inside a callback, not the build method
                context.read<AuthService>().logout();
              },
            ),
        ],
      ),
      // Use the 'user' from the provider to decide what to show
      body: user == null
          ? _buildLoginPrompt(context)
          : _buildProfileView(user, context),
    );
  }

  /// A widget to show when the user is not logged in.
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('You are not logged in.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToLogin(context),
            child: const Text('Login or Register'),
          ),
        ],
      ),
    );
  }

  /// The widget to show the user's profile information.
  Widget _buildProfileView(Map<String, dynamic> user, BuildContext context) {
    final name = user['name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';

    return RefreshIndicator(
      onRefresh: () => context.read<AuthService>().getCurrentUsers(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 20),
          _buildProfileAvatar(user),
          const SizedBox(height: 40),
          _buildInfoRow('Username', name),
          _buildInfoRow('Email', email),
          _buildInfoRow('Phone', 'Not Provided'),
          _buildInfoRow('Date of birth', 'Not Provided'),
          _buildInfoRow('Address', 'Not Provided'),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(Map<String, dynamic> user) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${user['email']}',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.teal.shade300,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}