import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class AttributeScreen extends StatefulWidget {
  const AttributeScreen({super.key});

  @override
  State<AttributeScreen> createState() => _AttributeScreenState();
}

class _AttributeScreenState extends State<AttributeScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _attributes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttributes();
  }

  Future<void> _fetchAttributes() async {
    setState(() => _isLoading = true);
    final attributes = await _authService.getAttributes();
    if (mounted) {
      setState(() {
        _attributes = attributes;
        _isLoading = false;
      });
    }
  }

  void _deleteAttribute(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete the attribute.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _authService.deleteAttribute(id);
      _showSnackbar('Attribute deleted ${success ? 'successfully' : 'failed'}', success);
      if (success) _fetchAttributes();
    }
  }

  void _showAttributeDialog({Map<String, dynamic>? attribute}) {
    final isEditing = attribute != null;
    final typeController = TextEditingController(text: isEditing ? attribute['type'] : '');
    final valueController = TextEditingController(text: isEditing ? attribute['value'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Attribute' : 'Add Attribute'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Type (e.g., Color, Size)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value (e.g., Red, XL)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final type = typeController.text;
                final value = valueController.text;
                if(type.isEmpty || value.isEmpty) return;

                bool success;
                if (isEditing) {
                  success = await _authService.updateAttribute(attribute['id'], type, value);
                } else {
                  success = await _authService.addAttribute(type, value);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _showSnackbar('Attribute ${isEditing ? 'updated' : 'added'} ${success ? 'successfully' : 'failed'}', success);
                }

                if (success) _fetchAttributes();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message, bool isSuccess) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attributes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Attribute',
            onPressed: () => _showAttributeDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAttributes,
        child: ListView.builder(
          itemCount: _attributes.length,
          itemBuilder: (context, index) {
            final attribute = _attributes[index];
            return ListTile(
              title: Text(attribute['value']),
              subtitle: Text(attribute['type']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showAttributeDialog(attribute: attribute),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAttribute(attribute['id']),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}