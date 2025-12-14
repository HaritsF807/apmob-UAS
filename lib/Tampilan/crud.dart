import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../API/layanan_api.dart';
import '../utils/constants.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final LayananApi layananApi = LayananApi();
  bool isLoading = false;
  String status = 'available';

  @override
  void initState() {
    super.initState();
    
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      descriptionController.text = widget.product!.description ?? '';
      priceController.text = widget.product!.price.toString();
      status = widget.product!.status;
    }
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final data = {
        'name': nameController.text,
        'description': descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        'price': double.parse(priceController.text),
        'status': status,
      };

      if (widget.product?.id != null) {
        await layananApi.perbaruiProduk(widget.product!.id!, data);
      } else {
        await layananApi.buatProduk(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null
                  ? 'Product Berhasil Diupdate'
                  : 'Product Berhasil Dibuat',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null ? 'Ubah Product' : 'Buat Product',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Product *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (v) => v!.isEmpty ? 'Nama Product Harus Diisi' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Product (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Harga Product *',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Harga Product Harus Diisi';
                if (double.tryParse(v) == null) return 'Invalid Harga Product';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Status Product',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Available'),
                    value: 'available',
                    groupValue: status,
                    onChanged: (val) => setState(() => status = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Unavailable'),
                    value: 'unavailable',
                    groupValue: status,
                    onChanged: (val) => setState(() => status = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColorValue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.product != null ? 'Ubah Product' : 'Buat Product',
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
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
