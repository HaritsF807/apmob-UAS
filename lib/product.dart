// FILE INI ADALAH: Form untuk Tambah dan Edit Produk
// Bisa dipakai untuk 2 mode:
// 1. Mode Tambah - Membuat produk baru
// 2. Mode Edit - Mengubah produk yang sudah ada

import 'package:flutter/material.dart';
import 'api.dart';

// ==================== STATEFUL WIDGET ====================
// StatefulWidget karena ada data yang berubah-ubah (input form, dropdown, dll)
class ProductFormScreen extends StatefulWidget {
  // Terima data produk (nullable) - kalo ada berarti mode edit, kalo null berarti mode tambah
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => ProductFormScreenState();
}

// ==================== STATE CLASS ====================
class ProductFormScreenState extends State<ProductFormScreen> {
  // Key untuk validasi form
  final formKey = GlobalKey<FormState>();
  
  // Controller untuk input text - Nama Produk
  final nameController = TextEditingController();
  
  // Controller untuk input text - Harga
  final priceController = TextEditingController();

  // List kategori yang diambil dari backend
  List<Map<String, dynamic>> categories = [];
  
  // Index kategori yang dipilih di dropdown (null = belum pilih)
  int? selectedCategoryIndex;
  
  // Status produk yang dipilih (default: available/tersedia)
  String selectedStatus = 'available';
  
  // Flag loading saat submit form
  bool isLoading = false;
  
  // Flag loading saat ambil kategori dari backend
  bool isLoadingCategories = true;

  // Opsi status produk untuk dropdown
  final List<Map<String, String>> statusOptions = [
    {'value': 'available', 'label': 'Tersedia'},      // Produk tersedia
    {'value': 'unavailable', 'label': 'Habis'},       // Produk habis
  ];

  // ==================== CEK MODE EDIT/TAMBAH ====================
  // Getter untuk cek apakah sedang mode edit atau tambah
  // Kalo widget.product ada isinya = mode EDIT
  // Kalo widget.product null = mode TAMBAH
  bool get isEditMode => widget.product != null;

  // ==================== INIT STATE ====================
  // Dipanggil pertama kali saat screen dibuka
  @override
  void initState() {
    super.initState();

    // JIKA MODE EDIT: Isi form dengan data produk yang mau diedit
    if (isEditMode) {
      // Ambil nama produk dan masukkan ke input field
      nameController.text = widget.product!['name'] ?? '';
      
      // Ambil harga produk dan convert ke string untuk input field
      priceController.text = widget.product!['price']?.toString() ?? '';
      
      // Set status produk (tersedia/habis)
      selectedStatus = widget.product!['status'] ?? 'available';
    }

    // Ambil daftar kategori dari backend (untuk dropdown)
    loadCategories();
  }

  // ==================== DISPOSE ====================
  // Dipanggil saat screen ditutup - bersihkan controller untuk hemat memory
  @override
  void dispose() {
    nameController.dispose();   // Hapus controller nama
    priceController.dispose();  // Hapus controller harga
    super.dispose();
  }

  // ==================== LOAD CATEGORIES ====================
  // Ambil daftar kategori dari backend untuk dropdown
  Future<void> loadCategories() async {
    try {
      // Panggil API untuk ambil semua kategori
      final cats = await ApiService.getCategories();

      // Cek apakah widget masih ada (belum di-dispose)
      if (mounted) {
        setState(() {
          // Simpan data kategori
          categories = cats;
          
          // Matikan loading
          isLoadingCategories = false;

          // JIKA MODE EDIT: Cari kategori mana yang dipilih produk ini
          if (isEditMode && categories.isNotEmpty) {
            // Ambil ID kategori dari produk
            final categoryId = widget.product!['category_id'];
            
            // Cari index kategori di list berdasarkan ID
            final index = categories.indexWhere((cat) => cat['id'] == categoryId);
            
            if (index != -1) {
              // Kalo ketemu, set sebagai pilihan
              selectedCategoryIndex = index;
            } else if (categories.isNotEmpty) {
              // Kalo ga ketemu, pilih kategori pertama
              selectedCategoryIndex = 0;
            }
          } 
          // JIKA MODE TAMBAH: Otomatis pilih kategori pertama
          else if (categories.isNotEmpty) {
            selectedCategoryIndex = 0;
          }
        });
      }
    } catch (e) {
      // Kalo error saat ambil kategori
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
        
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kategori: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== SUBMIT FORM ====================
  // Proses submit form - bisa untuk TAMBAH atau EDIT produk
  Future<void> submitForm() async {
    // Validasi form - cek apakah semua input valid
    if (!formKey.currentState!.validate()) return;

    // Cek apakah kategori sudah dipilih
    if (selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Nyalakan loading
    setState(() {
      isLoading = true;
    });

    try {
      // Parse harga dari string ke double
      final price = double.parse(priceController.text);
      
      // Ambil kategori yang dipilih
      final selectedCategory = categories[selectedCategoryIndex!];

      // Ambil ID kategori dan convert ke string
      final categoryId = (selectedCategory['id'] ?? '').toString();

      // Validasi category ID tidak boleh kosong
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

      // Variable untuk menyimpan hasil dari API
      Map<String, dynamic> result;

      // ===== CEK MODE: EDIT ATAU TAMBAH =====
      if (isEditMode) {
        // MODE EDIT: Update produk yang sudah ada
        result = await ApiService.updateProduct(
          // Ambil product ID (bisa dari 'product_id' atau 'id')
          productId: widget.product!['product_id'] ?? widget.product!['id'].toString(),
          name: nameController.text,        // Nama produk baru
          categoryId: categoryId,            // ID kategori yang dipilih
          price: price,                      // Harga baru
          status: selectedStatus,            // Status baru (tersedia/habis)
        );
      } else {
        // MODE TAMBAH: Buat produk baru
        result = await ApiService.createProduct(
          name: nameController.text,         // Nama produk
          categoryId: categoryId,            // ID kategori yang dipilih
          price: price,                      // Harga
          status: selectedStatus,            // Status (tersedia/habis)
        );
      }

      // Cek apakah widget masih ada
      if (!mounted) return;

      // ===== CEK HASIL API =====
      if (result['success']) {
        // BERHASIL: Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kembali ke halaman sebelumnya dengan result = true
        // true = berhasil, supaya product list bisa refresh
        Navigator.pop(context, true);
      } else {
        // GAGAL: Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Kalo ada error (misal: koneksi gagal, parsing error, dll)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Matikan loading (dijalankan apapun hasilnya)
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar dengan title dinamis (Edit/Tambah)
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk'),
      ),
      
      body: isLoadingCategories
          // Tampilkan loading saat ambil kategori
          ? const Center(child: CircularProgressIndicator())
          
          // Tampilkan form setelah kategori selesai di-load
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,  // Key untuk validasi form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== INPUT NAMA PRODUK =====
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Validasi: Nama tidak boleh kosong
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ===== INPUT HARGA =====
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,  // Keyboard angka
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixText: 'Rp ',  // Prefix "Rp " di depan
                      ),
                      // Validasi: Harga harus angka dan tidak boleh kosong
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

                    // ===== DROPDOWN KATEGORI =====
                    if (categories.isEmpty)
                      // Tampilkan peringatan jika tidak ada kategori
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
                      // Tampilkan dropdown kategori
                      DropdownButtonFormField<int>(
                        value: selectedCategoryIndex,  // Kategori yang dipilih
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Generate dropdown items dari list categories
                        items: List.generate(categories.length, (index) {
                          return DropdownMenuItem<int>(
                            value: index,                          // Value = index
                            child: Text(categories[index]['name']), // Text = nama kategori
                          );
                        }),
                        // Saat pilihan berubah
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryIndex = value;
                          });
                        },
                        // Validasi: Kategori harus dipilih
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kategori';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // ===== DROPDOWN STATUS =====
                    DropdownButtonFormField<String>(
                      value: selectedStatus,  // Status yang dipilih
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Generate dropdown items dari statusOptions
                      items: statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['value'],   // Value = 'available' atau 'unavailable'
                          child: Text(status['label']!),  // Text = 'Tersedia' atau 'Habis'
                        );
                      }).toList(),
                      // Saat pilihan berubah
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value ?? 'available';
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // ===== TOMBOL SUBMIT =====
                    ElevatedButton(
                      // Disable button kalo sedang loading atau tidak ada kategori
                      onPressed: (isLoading || categories.isEmpty) ? null : submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          // Tampilkan loading indicator saat submit
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          // Tampilkan text button (Update/Tambah)
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
