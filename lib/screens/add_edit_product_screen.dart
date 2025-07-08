import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_service.dart';

class AddEditProductScreen extends StatefulWidget {
  // If a product is passed, we are in "Edit" mode.
  // If it's null, we are in "Add" mode.
  final Map<String, dynamic>? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _picker = ImagePicker();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _regularPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _descriptionController;

  // State for selections
  int? _selectedCategoryId;
  final List<int> _selectedSizeIds = [];
  final List<int> _selectedColorIds = [];
  XFile? _selectedImage;
  String? _existingImageUrl;

  // Data from API
  List<dynamic> _categories = [];
  List<dynamic> _sizes = [];
  List<dynamic> _colors = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    final isEditing = widget.product != null;
    _nameController = TextEditingController(text: isEditing ? widget.product!['name'] : '');
    _qtyController = TextEditingController(text: isEditing ? widget.product!['quantity'].toString() : '');
    _regularPriceController = TextEditingController(text: isEditing ? widget.product!['regular_price'].toString() : '');
    _salePriceController = TextEditingController(text: isEditing ? widget.product!['sale_price'].toString() : '');
    _descriptionController = TextEditingController(text: isEditing ? widget.product!['description'] : '');
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _authService.getCategories(),
        _authService.getAttributes(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0];
          final allAttributes = results[1];
          _sizes = allAttributes.where((attr) => attr['type'].toLowerCase() == 'size').toList();
          _colors = allAttributes.where((attr) => attr['type'].toLowerCase() == 'color').toList();

          if (widget.product != null) {
            _selectedCategoryId = widget.product!['category'];
            _existingImageUrl = widget.product!['thumbnail_url'];

            final attributes = widget.product!['attributes'];
            if(attributes['Size'] != null) {
              _selectedSizeIds.addAll((attributes['Size'] as List).map((e) => e['id'] as int));
            }
            if(attributes['Color'] != null) {
              _selectedColorIds.addAll((attributes['Color'] as List).map((e) => e['id'] as int));
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackbar('Failed to load necessary data: $e', false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if(image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showSnackbar('Please select a category.', false);
      return;
    }

    setState(() => _isSaving = true);

    final fields = {
      'name': _nameController.text,
      'qty': _qtyController.text,
      'regular_price': _regularPriceController.text,
      'sale_price': _salePriceController.text,
      'description': _descriptionController.text,
      'category': _selectedCategoryId.toString(),
    };

    final sizeIds = _selectedSizeIds.map((id) => id.toString()).toList();
    final colorIds = _selectedColorIds.map((id) => id.toString()).toList();

    bool success;
    if (widget.product != null) {
      success = await _authService.updateProduct(widget.product!['id'], fields, sizeIds, colorIds, _selectedImage);
    } else {
      success = await _authService.addProduct(fields, sizeIds, colorIds, _selectedImage);
    }

    setState(() => _isSaving = false);

    if(mounted) {
      _showSnackbar('Product ${widget.product != null ? 'updated' : 'added'} ${success ? 'successfully' : 'failed'}', success);
      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    }
  }

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
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _submitForm, tooltip: 'Save'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Image Picker Section
            _buildImagePicker(),
            const SizedBox(height: 16),

            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v!.isEmpty ? 'Required field' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required field' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _regularPriceController, decoration: const InputDecoration(labelText: 'Regular Price'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required field' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _salePriceController, decoration: const InputDecoration(labelText: 'Sale Price'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required field' : null),
            const SizedBox(height: 8),

            // Category Dropdown
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              items: _categories.map<DropdownMenuItem<int>>((cat) => DropdownMenuItem<int>(value: cat['id'], child: Text(cat['name']))).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Sizes Section
            const Text('Sizes', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildAttributeChips(_sizes, _selectedSizeIds),
            const SizedBox(height: 16),

            // Colors Section
            const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildAttributeChips(_colors, _selectedColorIds),
            const SizedBox(height: 16),

            // Description
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: _selectedImage != null
                ? (kIsWeb ? Image.network(_selectedImage!.path, fit: BoxFit.cover) : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                : (_existingImageUrl != null ? Image.network(_existingImageUrl!, fit: BoxFit.cover) : const Center(child: Text('No Image'))),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const CircleAvatar(child: Icon(Icons.camera_alt)),
              onPressed: _pickImage,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAttributeChips(List<dynamic> attributes, List<int> selectedIds) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: attributes.map((attr) {
        final isSelected = selectedIds.contains(attr['id']);
        return FilterChip(
          label: Text(attr['value']),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) { selectedIds.add(attr['id']); }
              else { selectedIds.remove(attr['id']); }
            });
          },
          selectedColor: Colors.blue.shade100,
          checkmarkColor: Colors.blue.shade800,
        );
      }).toList(),
    );
  }
}