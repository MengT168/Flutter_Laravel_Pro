import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final categories = await _authService.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  void _deleteCategory(int id) async {
    final confirmed = await _showConfirmationDialog();
    if (confirmed == true) {
      final success = await _authService.deleteCategory(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted successfully'), backgroundColor: Colors.green));
        _fetchCategories(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete category'), backgroundColor: Colors.red));
      }
    }
  }

  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: isEditing ? category['name'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                bool success;
                if (isEditing) {
                  success = await _authService.updateCategory(category['id'], nameController.text);
                } else {
                  success = await _authService.addCategory(nameController.text);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Category ${isEditing ? 'updated' : 'added'} ${success ? 'successfully' : 'failed'}'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                  Navigator.pop(context);
                }

                if(success) _fetchCategories(); // Refresh list
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchCategories,
        child: ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return ListTile(
              title: Text(category['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCategoryDialog(category: category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(category['id']),
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