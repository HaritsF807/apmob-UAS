import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final List<Category> categories;

  const ProductFormScreen({
    super.key,
    this.product,
    required this.categories,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _selectedCategoryId;
  String _status = 'active';
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _categories = widget.categories;
    
    // Load categories if empty
    if (_categories.isEmpty) {
      _loadCategories();
    }
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _selectedCategoryId = widget.product!.categoryId;
      _status = widget.product!.status;
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categoryData = await _apiService.getCategories();
      setState(() {
        _categories = categoryData.map((json) => Category.fromJson(json)).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category_id': _selectedCategoryId,
        'status': _status,
      };

      if (widget.product?.id != null) {
        await _apiService.updateProduct(widget.product!.id!, data);
      } else {
        await _apiService.createProduct(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null
                  ? 'Product updated successfully'
                  : 'Product created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null ? 'Edit Product' : 'New Product',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price *',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Price is required';
                if (double.tryParse(v) == null) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _isLoadingCategories 
                  ? []
                  : _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                      .toList(),
              onChanged: _isLoadingCategories ? null : (val) => setState(() => _selectedCategoryId = val),
              validator: (v) => v == null ? 'Category is required' : null,
              hint: _isLoadingCategories 
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading categories...'),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Status Radio Buttons
            const Text(
              'Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Active'),
                    value: 'active',
                    groupValue: _status,
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Inactive'),
                    value: 'inactive',
                    groupValue: _status,
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColorValue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.product != null ? 'Update Product' : 'Create Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
