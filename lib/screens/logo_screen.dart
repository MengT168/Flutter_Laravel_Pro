import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_service.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _logos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogos();
  }

  /// Fetches the list of logos from the API.
  Future<void> _fetchLogos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _logos = await _authService.getLogos();
    if (mounted) setState(() => _isLoading = false);
  }

  /// Handles picking an image and uploading it for a new logo or updating an existing one.
  Future<void> _pickAndUploadImage({int? logoId}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    final isUpdating = logoId != null;
    _showLoadingDialog(isUpdating ? 'Updating...' : 'Uploading...');

    final bool success = isUpdating
        ? await _authService.updateLogo(logoId, image)
        : await _authService.addLogo(image);

    if (mounted) Navigator.pop(context);

    _showSnackbar('Logo ${isUpdating ? 'updated' : 'uploaded'} ${success ? 'successfully' : 'failed'}', success);
    if (success) _fetchLogos();
  }

  /// Toggles the active status of a logo.
  Future<void> _toggleStatus(int id) async {
    final success = await _authService.toggleLogoStatus(id);
    if (!success) {
      _showSnackbar('Failed to update status', false);
    }
    // Refresh the list to show the new status from the server
    await _fetchLogos();
  }

  /// Deletes a logo after user confirmation.
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
      final success = await _authService.deleteLogo(id);
      _showSnackbar('Logo deleted ${success ? 'successfully' : 'failed'}', success);
      if (success) _fetchLogos();
    }
  }

  /// Shows a simple loading dialog.
  void _showLoadingDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Shows a status message at the bottom of the screen.
  void _showSnackbar(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

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
                  backgroundColor: Colors.black45,
                  title: Text(isActive ? 'Active' : 'Inactive', style: const TextStyle(fontSize: 12)),
                  trailing: Switch(
                    value: isActive,
                    onChanged: (value) => _toggleStatus(logo['id']),
                    activeTrackColor: Colors.tealAccent,
                    activeColor: Colors.teal,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          return progress == null ? child : const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stack) =>
                        const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      )
                    else
                      const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'edit') _pickAndUploadImage(logoId: logo['id']);
                          if (value == 'delete') _deleteLogo(logo['id']);
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'edit', child: Text('Change Image')),
                          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}