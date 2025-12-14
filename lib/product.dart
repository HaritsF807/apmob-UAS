import 'package:flutter/material.dart';
import 'api.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // null = add mode, not null = edit mode

  const ProductFormScreen({super.key,this.product});

  @override
  State<ProductFormScreen> createState() => ProductFormScreenState();
}

class ProductFormScreenState extends State<ProductFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  
  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryIndex; // Changed to index instead of id
  String selectedStatus = 'available'; // Default value
  bool isLoading = false;
  bool isLoadingCategories = true;

  final List<Map<String, String>> statusOptions = [
    {'value': 'available', 'label': 'Tersedia'},
    {'value': 'unavailable', 'label': 'Habis'},
  ];

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      // Pre-fill form for edit mode
      nameController.text = widget.product!['name'] ?? '';
      priceController.text = widget.product!['price']?.toString() ?? '';
      selectedStatus = widget.product!['status'] ?? 'available';
    }
    
    loadCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      
      if (mounted) {
        setState(() {
          categories = cats;
          isLoadingCategories = false;
          
          // Set selected category by matching id (backend uses 'id' not 'category_id')
          if (isEditMode && categories.isNotEmpty) {
            final categoryId = widget.product!['category_id'];
            final index = categories.indexWhere((cat) => cat['id'] == categoryId);
            if (index != -1) {
              selectedCategoryIndex = index;
            } else if (categories.isNotEmpty) {
              selectedCategoryIndex = 0; // Fallback to first
            }
          } else if (categories.isNotEmpty) {
            // For add mode, select first category by default
            selectedCategoryIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kategori: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final price = double.parse(priceController.text);
      final selectedCategory = categories[selectedCategoryIndex!];
      
      // Safely get id (backend uses 'id' field for categories, not 'category_id')
      final categoryId = (selectedCategory['id'] ?? '').toString();
      
      // Validate categoryId is not empty
      if (categoryId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category ID tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      print('Category ID: $categoryId');
      print('Name: ${nameController.text}');
      print('Price: $price');
      print('Status: $selectedStatus');
      
      Map<String, dynamic> result;
      
      if (isEditMode) {
        // Update product
        result = await ApiService.updateProduct(
          productId: widget.product!['product_id'] ?? widget.product!['id'].toString(),
          name: nameController.text,
          categoryId: categoryId,
          price: price,
          status: selectedStatus,
        );
      } else {
        // Create product
        result = await ApiService.createProduct(
          name: nameController.text,
          categoryId: categoryId,
          price: price,
          status: selectedStatus,
        );
      }

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Produk *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'Rp ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    if (categories.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Tidak ada kategori. Tambahkan kategori terlebih dahulu.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: selectedCategoryIndex,
                        decoration: InputDecoration(
                          labelText: 'Kategori *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: List.generate(categories.length, (index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(categories[index]['name']),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryIndex = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kategori';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.check_circle),
                      ),
                      items: statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['value'],
                          child: Text(status['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value ?? 'available';
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: (isLoading || categories.isEmpty) ? null : submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditMode ? 'Update Produk' : 'Tambah Produk',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
