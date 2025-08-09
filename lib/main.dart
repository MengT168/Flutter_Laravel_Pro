import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/auth/auth_service.dart';
import 'package:lara_flutter_pro/providers/locale_provider.dart';
import 'package:lara_flutter_pro/providers/theme_provider.dart';
import 'package:lara_flutter_pro/screens/auth_wrapper.dart';

import 'package:lara_flutter_pro/theme/theme.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(
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
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,

      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      home: const AuthWrapper(),
    );
  }
}