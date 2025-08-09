import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/providers/locale_provider.dart';
import 'package:lara_flutter_pro/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This line "watches" AuthService for changes and rebuilds the screen automatically.
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        actions: [
          // Only show the logout button if the user is logged in
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                // Call logout directly from the provider.
                context.read<AuthService>().logout();
              },
            ),
        ],
      ),
      body: user == null
          ? _buildLoginPrompt(context, localizations)
          : _buildProfileView(context, user, localizations),
    );
  }

  /// A widget to show when the user is not logged in.
  Widget _buildLoginPrompt(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.youAreNotLoggedIn,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(isPoppingOnSuccess: true),
                ),
              );
            },
            child: Text(localizations.loginOrRegister),
          ),
        ],
      ),
    );
  }

  /// The widget to show the user's profile information.
  Widget _buildProfileView(BuildContext context, Map<String, dynamic> user, AppLocalizations localizations) {
    final name = user['name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';

    return RefreshIndicator(
      onRefresh: () => context.read<AuthService>().getCurrentUser(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          _buildProfileAvatar(context, user),
          const SizedBox(height: 40),
          _buildInfoRow(context, localizations.username, name),
          _buildInfoRow(context, localizations.email, email),
          // _buildInfoRow(context, localizations.phone as String, 'Not Provided'),
          _buildInfoRow(context, localizations.dateOfBirth, 'Not Provided'),
          // _buildInfoRow(context, localizations.address as String, 'Not Provided'),
          const Divider(height: 40),
          _buildSettingsSection(context, localizations),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, Map<String, dynamic> user) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${user['email']}',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSecondary, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.appearance, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(localizations.light), icon: const Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text(localizations.system), icon: const Icon(Icons.brightness_auto_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text(localizations.dark), icon: const Icon(Icons.dark_mode_outlined)),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                context.read<ThemeProvider>().setThemeMode(newSelection.first);
              },
            );
          },
        ),

        const SizedBox(height: 24),

        Text(localizations.language, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => context.read<LocaleProvider>().setLocale(const Locale('en')), child: Text(localizations.english)),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: () => context.read<LocaleProvider>().setLocale(const Locale('km')), child: const Text('ខ្មែរ')),
          ],
        ),
      ],
    );
  }
}