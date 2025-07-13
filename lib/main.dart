import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/login_screen.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'auth/auth_service.dart';

void main() {
  runApp(
    // 1. Wrap your entire app with ChangeNotifierProvider.
    // This creates one single instance of AuthService for your whole app.
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Laravel Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
