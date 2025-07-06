import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/attribute_screen.dart';
import 'package:lara_flutter_pro/screens/category_screen.dart';
import 'package:lara_flutter_pro/screens/logo_screen.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _adminUser;
  int _categoryCount = 0;
  int _attributeCount = 0;
  int _logoCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  /// Fetches all necessary data for the dashboard concurrently.
  Future<void> _fetchDashboardData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // Fetch all data points at the same time for efficiency
      final results = await Future.wait([
        _authService.getCurrentUser(),
        _authService.getCategories(),
        _authService.getAttributes(),
        _authService.getLogos(),
      ]);

      if (mounted) {
        setState(() {
          _adminUser = results[0] as Map<String, dynamic>?;
          _categoryCount = (results[1] as List).length;
          _attributeCount = (results[2] as List).length;
          _logoCount = (results[3] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to load dashboard data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dynamic Admin User Info Card
              ListTile(
                leading: const Icon(Icons.person_pin_circle, size: 40, color: Colors.black54),
                title: Text(
                  _adminUser?['name'] ?? 'Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _adminUser?['email'] ?? 'Administrator Access',
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(),
                child: const Text('Delivery Prices'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(),
                child: const Text('Send notification to all users'),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('0', 'Users'), // Placeholder

                  // Categories Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryScreen()),
                      ).then((_) => _fetchDashboardData()); // Refresh on return
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildStatCard(
                      _categoryCount.toString(),
                      'Categories',
                    ),
                  ),

                  // Attributes Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttributeScreen()),
                      ).then((_) => _fetchDashboardData()); // Refresh on return
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildStatCard(
                      _attributeCount.toString(),
                      'Attributes',
                    ),
                  ),

                  // Logos Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LogoScreen()),
                      ).then((_) => _fetchDashboardData()); // Refresh on return
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildStatCard(
                      _logoCount.toString(),
                      'Logos',
                    ),
                  ),

                  _buildStatCard('0', 'Products'), // Placeholder
                  _buildStatCard('\$0.00', 'Earnings'), // Placeholder
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for stat card UI
  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for button styling
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFC07F26),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}