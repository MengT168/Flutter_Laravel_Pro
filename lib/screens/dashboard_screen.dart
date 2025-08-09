import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/attribute_screen.dart';
import 'package:lara_flutter_pro/screens/category_screen.dart';
import 'package:lara_flutter_pro/screens/logo_screen.dart';
import 'package:lara_flutter_pro/screens/product_list_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _adminUser;
  int _categoryCount = 0;
  int _attributeCount = 0;
  int _logoCount = 0;
  int _productCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (mounted) setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    try {
      final results = await Future.wait([
        authService.getCurrentUser(),
        authService.getCategories(),
        authService.getAttributes(),
        authService.getLogos(),
        authService.getProducts(),
      ]);

      if (mounted) {
        setState(() {
          _adminUser = results[0] as Map<String, dynamic>?;
          _categoryCount = (results[1] as List).length;
          _attributeCount = (results[2] as List).length;
          _logoCount = (results[3] as List).length;
          _productCount = (results[4] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboard), // <-- TRANSLATED
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: localizations.logout, // <-- TRANSLATED
            onPressed: () async {
              await authService.logout();
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
              ListTile(
                leading: const Icon(Icons.person_pin_circle, size: 40),
                title: Text(
                  _adminUser?['name'] ?? 'Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _adminUser?['email'] ?? localizations.administratorAccess, // <-- TRANSLATED
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(),
                child: Text(localizations.deliveryPrices), // <-- TRANSLATED
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(),
                child: Text(localizations.sendNotification), // <-- TRANSLATED
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('0', localizations.users), // <-- TRANSLATED
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_categoryCount.toString(), localizations.categories), // <-- TRANSLATED
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttributeScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_attributeCount.toString(), localizations.attributes), // <-- TRANSLATED
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogoScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_logoCount.toString(), localizations.logout), // <-- TRANSLATED
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_productCount.toString(), localizations.products), // <-- TRANSLATED
                  ),
                  _buildStatCard('\$0.00', localizations.earnings), // <-- TRANSLATED
                  _buildStatCard('0', localizations.pendingOrders), // <-- TRANSLATED
                  _buildStatCard('0', localizations.ordersInProgress), // <-- TRANSLATED
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

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