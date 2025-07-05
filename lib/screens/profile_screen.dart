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

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Could not load user profile.'))
          : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    final name = _user!['name'] ?? 'N/A';
    final email = _user!['email'] ?? 'N/A';
    final phone = _user!['phone'] ?? '+65 2311 333'; // Example placeholder
    final dob = _user!['dob'] ?? '20/05/1990';      // Example placeholder
    final address = _user!['address'] ?? '123 Royal Street, New York'; // Example placeholder

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        const SizedBox(height: 20),
        _buildProfileAvatar(),
        const SizedBox(height: 40),
        _buildInfoRow('Username', name),
        _buildInfoRow('Email', email),
        _buildInfoRow('Phone', phone),
        _buildInfoRow('Date of birth', dob),
        _buildInfoRow('Address', address),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              // Using a placeholder image, replace with user's actual avatar URL if available
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
                onPressed: () {
                  // TODO: Implement image picker logic
                },
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}