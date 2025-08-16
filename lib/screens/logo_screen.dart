import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _logos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogos();
  }

  Future<void> _fetchLogos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _logos = await context.read<AuthService>().getLogos();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadImage({int? logoId}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    final isUpdating = logoId != null;
    _showLoadingDialog(isUpdating ? 'Updating...' : 'Uploading...');

    final authService = context.read<AuthService>();
    final bool success = isUpdating
        ? await authService.updateLogo(logoId, image)
        : await authService.addLogo(image);

    if (mounted) Navigator.pop(context); // Close loading dialog

    _showSnackbar('Logo ${isUpdating ? 'updated' : 'uploaded'} ${success ? 'successfully' : 'failed'}', success);
    if (success) _fetchLogos();
  }

  Future<void> _toggleStatus(int id) async {
    final success = await context.read<AuthService>().toggleLogoStatus(id);
    if (!success) {
      _showSnackbar('Failed to update status', false);
    }
    await _fetchLogos();
  }

  Future<void> _deleteLogo(int id) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Logo?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ));

    if (confirmed == true) {
      final success = await context.read<AuthService>().deleteLogo(id);
      _showSnackbar('Logo deleted ${success ? 'successfully' : 'failed'}', success);
      if (success) _fetchLogos();
    }
  }

  void _showLoadingDialog(String message) { /* ... same as before ... */ }
  void _showSnackbar(String message, bool isSuccess) { /* ... same as before ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Logos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Add Logo',
            onPressed: () => _pickAndUploadImage(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchLogos,
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8, // Adjust aspect ratio for more space
          ),
          itemCount: _logos.length,
          itemBuilder: (context, index) {
            final logo = _logos[index];
            final bool isActive = logo['status'] == 1;
            final String? imageUrl = logo['thumbnail_url'];

            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: SwitchListTile(
                    title: Text(isActive ? 'Active' : 'Inactive', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    value: isActive,
                    onChanged: (value) => _toggleStatus(logo['id']),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  // ** THE CHANGE IS HERE: More visible buttons **
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () => _pickAndUploadImage(logoId: logo['id']),
                        tooltip: 'Change Image',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: () => _deleteLogo(logo['id']),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
                child: (imageUrl != null)
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                )
                    : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}