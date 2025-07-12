import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches user data. If the user is not logged in, the service will return null.
  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUserII();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  /// Handles navigating to the login screen and refreshing data upon return.
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the new parameter here
        builder: (context) => const LoginScreen(isFromProfile: true),
      ),
    ).then((_) {
      // After returning from login, refresh the user data
      _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // Only show the logout button if the user is logged in
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await _authService.logout();
                // Immediately clear the user data for UI update
                setState(() {
                  _user = null;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
      // If user is null, show login prompt. Otherwise, show profile.
          : _user == null
          ? _buildLoginPrompt()
          : _buildProfileView(),
    );
  }

  /// A widget to show when the user is not logged in.
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'You are not logged in.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToLogin,
            child: const Text('Login or Register'),
          ),
        ],
      ),
    );
  }

  /// The widget to show the user's profile information.
  Widget _buildProfileView() {
    final name = _user!['name'] ?? 'N/A';
    final email = _user!['email'] ?? 'N/A';

    return RefreshIndicator(
      onRefresh: _fetchUserData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 20),
          _buildProfileAvatar(),
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

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${_user!['email']}',
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