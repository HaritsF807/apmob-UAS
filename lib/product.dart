import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  ProductFormScreen({this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryIndex;
  String selectedStatus = 'available';
  bool isLoading = false;
  bool isLoadingCategories = true;

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      nameController.text = widget.product!['name'] ?? '';
      priceController.text = widget.product!['price']?.toString() ?? '';
      selectedStatus = widget.product!['status'] ?? 'available';
    }

    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['data']);
          isLoadingCategories = false;

          if (isEditMode && categories.isNotEmpty) {
            final categoryId = widget.product!['category_id'];
            final index = categories.indexWhere((cat) => cat['id'] == categoryId);
            if (index != -1) {
              selectedCategoryIndex = index;
            } else if (categories.isNotEmpty) {
              selectedCategoryIndex = 0;
            }
          } else if (categories.isNotEmpty) {
            selectedCategoryIndex = 0;
          }
        });
      }
    } catch (e) {
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

  Future<void> submitForm() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama produk tidak boleh kosong'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (priceController.text.isEmpty || double.tryParse(priceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harga harus berupa angka'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih kategori terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final price = double.parse(priceController.text);
      final selectedCategory = categories[selectedCategoryIndex!];
      final categoryId = (selectedCategory['id'] ?? '').toString();

      if (categoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category ID tidak valid'), backgroundColor: Colors.red),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final body = jsonEncode({
        'name': nameController.text,
        'category_id': categoryId,
        'price': price.toString(),
        'description': '-',
        'status': selectedStatus,
      });

      http.Response response;

      if (isEditMode) {
        final productId = widget.product!['product_id'] ?? widget.product!['id'].toString();
        response = await http.put(
          Uri.parse('http://127.0.0.1:8000/api/products/$productId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );
      } else {
        response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/products'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']?.toString() ?? 'Berhasil'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']?.toString() ?? 'Gagal'),
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixText: 'Rp ',
                    ),
                  ),
                  SizedBox(height: 16),

                  if (categories.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        'Tidak ada kategori. Tambahkan kategori terlebih dahulu.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: selectedCategoryIndex,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      DropdownMenuItem(value: 'available', child: Text('Tersedia')),
                      DropdownMenuItem(value: 'unavailable', child: Text('Habis')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? 'available';
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: (isLoading || categories.isEmpty) ? null : submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Produk' : 'Tambah Produk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
