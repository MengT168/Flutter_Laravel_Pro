import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/auth/auth_service.dart';
import 'package:lara_flutter_pro/screens/cart_screen.dart';
import 'package:lara_flutter_pro/screens/home_screen.dart';
import 'package:lara_flutter_pro/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'OrderScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // bool _isInitializing = true;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _initializeUser();
  // }
  //
  // Future<void> _initializeUser() async {
  //   // We use context.read because we are in initState and only need to call this once.
  //   await context.read<AuthService>().getCurrentUsers();
  //
  //   if (mounted) {
  //     setState(() {
  //       _isInitializing = false;
  //     });
  //   }
  // }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    OrderScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // if (_isInitializing) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: localizations.home, // <-- TRANSLATED
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: localizations.orders, // <-- TRANSLATED
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            activeIcon: const Icon(Icons.shopping_cart),
            label: localizations.cart, // <-- TRANSLATED
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: localizations.profile, // <-- TRANSLATED
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}