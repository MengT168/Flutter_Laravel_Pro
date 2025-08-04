import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/auth/auth_service.dart';
import 'package:lara_flutter_pro/providers/locale_provider.dart';
import 'package:lara_flutter_pro/providers/theme_provider.dart';

import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:lara_flutter_pro/theme/theme.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(
    // Use MultiProvider to hold all your app-wide services
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the providers for changes to automatically rebuild the app
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,

      // --- Theme Configuration ---
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,

      // --- Localization Configuration ---
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      home: const MainScreen(),
    );
  }
}