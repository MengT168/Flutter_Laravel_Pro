import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';

import '../l10n/app_localizations.dart'; // <-- Add this import

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
                localizations.orderPlacedSuccess, // <-- TRANSLATED
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(localizations.thankYouPurchase), // <-- TRANSLATED
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                );
              },
              child: Text(localizations.continueShopping), // <-- TRANSLATED
            )
          ],
        ),
      ),
    );
  }
}