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
    final authService = context.watch<AuthService>();
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        // REMOVED: backgroundColor and foregroundColor to let the theme handle it
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthService>().logout();
              },
            ),
        ],
      ),
      body: user == null
          ? _buildLoginPrompt(context)
          : _buildProfileView(context, user),
    );
  }

  /// A widget to show when the user is not logged in.
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            // Use a theme color that adapts
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'You are not logged in.',
            // Use a theme text style that adapts
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
            child: const Text('Login or Register'),
          ),
        ],
      ),
    );
  }

  /// The widget to show the user's profile information.
  Widget _buildProfileView(BuildContext context, Map<String, dynamic> user) {
    final name = user['name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';

    return RefreshIndicator(
      onRefresh: () => context.read<AuthService>().getCurrentUser(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          _buildProfileAvatar(context, user),
          const SizedBox(height: 40),
          _buildInfoRow(context, 'Username', name),
          _buildInfoRow(context, 'Email', email),
          _buildInfoRow(context, 'Phone', 'Not Provided'),
          _buildInfoRow(context, 'Date of birth', 'Not Provided'),
          _buildInfoRow(context, 'Address', 'Not Provided'),
          const Divider(height: 40),
          _buildSettingsSection(context),
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
              // Use the theme's secondary color
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
          // Use the theme's text style for less important text
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          // Use the theme's text style for the main text
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    // This section was already using theme-aware widgets, so it's fine
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appearance", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                context.read<ThemeProvider>().setThemeMode(newSelection.first);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        Text("Language", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => context.read<LocaleProvider>().setLocale(const Locale('en')), child: const Text('English')),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: () => context.read<LocaleProvider>().setLocale(const Locale('km')), child: const Text('ខ្មែរ')),
          ],
        ),
      ],
    );
  }
}