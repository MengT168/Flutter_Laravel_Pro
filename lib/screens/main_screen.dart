import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/auth/auth_service.dart';
import 'package:lara_flutter_pro/screens/cart_screen.dart';
import 'package:lara_flutter_pro/screens/home_screen.dart';
import 'package:lara_flutter_pro/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import 'OrderScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // This function runs when the app starts to load a saved user session.
  Future<void> _initializeUser() async {
    // We use context.read because we are in initState and only need to call this once.
    await context.read<AuthService>().getCurrentUsers();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // The list of screens for your bottom navigation bar.
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
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
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