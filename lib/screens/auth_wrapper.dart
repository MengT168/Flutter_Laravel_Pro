import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/dashboard_screen.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    Provider.of<AuthService>(context, listen: false).getCurrentUsers().then((_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authService = context.watch<AuthService>();
    final bool isAdmin = authService.user?['is_admin'] == 1;

    if (isAdmin) {
      return const DashboardScreen();
    } else {
      return const MainScreen();
    }
  }
}