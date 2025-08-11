import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/providers/locale_provider.dart';
import 'package:lara_flutter_pro/providers/theme_provider.dart';
import 'package:lara_flutter_pro/screens/admin_order_screen.dart';
import 'package:lara_flutter_pro/screens/attribute_screen.dart';
import 'package:lara_flutter_pro/screens/category_screen.dart';
import 'package:lara_flutter_pro/screens/logo_screen.dart';
import 'package:lara_flutter_pro/screens/product_list_screen.dart';
import 'package:lara_flutter_pro/screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

import '../l10n/app_localizations.dart';

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
  int _pendingOrderCount = 0;
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
      // Fetch all data points at the same time for efficiency
      final results = await Future.wait([
        authService.getCurrentUser(),
        authService.getCategories(),
        authService.getAttributes(),
        authService.getLogos(),
        authService.getProducts(),
        authService.getListOrder(), // <-- Fetch order data
      ]);

      if (mounted) {
        setState(() {
          _adminUser = results[0] as Map<String, dynamic>?;
          _categoryCount = (results[1] as List).length;
          _attributeCount = (results[2] as List).length;
          _logoCount = (results[3] as List).length;
          _productCount = (results[4] as List).length;
          final orderData = results[5] as Map<String, dynamic>?;
          _pendingOrderCount = orderData?['pending_count'] ?? 0; // <-- Store pending order count
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSettingsDialog() {
    final themeProvider = context.read<ThemeProvider>();
    final localeProvider = context.read<LocaleProvider>();
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.settings),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.appearance, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(value: ThemeMode.light, label: Text(localizations.light), icon: const Icon(Icons.light_mode_outlined)),
                        ButtonSegment(value: ThemeMode.system, label: Text(localizations.system), icon: const Icon(Icons.brightness_auto_outlined)),
                        ButtonSegment(value: ThemeMode.dark, label: Text(localizations.dark), icon: const Icon(Icons.dark_mode_outlined)),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        themeProvider.setThemeMode(newSelection.first);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(localizations.language, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<Locale>(
                      segments: [
                        ButtonSegment(value: const Locale('en'), label: Text(localizations.english)),
                        ButtonSegment(value: const Locale('km'), label: const Text('ខ្មែរ')),
                      ],
                      selected: {localeProvider.locale ?? Localizations.localeOf(context)},
                      onSelectionChanged: (Set<Locale> newSelection) {
                        localeProvider.setLocale(newSelection.first);
                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.home),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: localizations.settings,
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: localizations.logout,
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
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
                  _adminUser?['email'] ?? localizations.administratorAccess,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(context),
                child: Text(localizations.deliveryPrices),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: _buttonStyle(context),
                child: Text(localizations.sendNotification),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('0', localizations.users),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_categoryCount.toString(), localizations.categories),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttributeScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_attributeCount.toString(), localizations.attributes),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogoScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_logoCount.toString(), localizations.logos),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())).then((_) => _fetchDashboardData()),
                    child: _buildStatCard(_productCount.toString(), localizations.products),
                  ),
                  _buildStatCard('\$0.00', localizations.earnings),
                  // THE NEW MANAGE ORDERS CARD
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrderScreen()))
                          .then((_) => _fetchDashboardData());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildStatCard(
                      _pendingOrderCount.toString(),
                      localizations.pendingOrders,
                    ),
                  ),
                  _buildStatCard('0', localizations.ordersInProgress),
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
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}