import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class LayananApi {
  Future<String?> ambilToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> simpanToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> hapusToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> _ambilHeaders() async {
    final token = await ambilToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<List<Map<String, dynamic>>> ambilProduk() async {
    final url = Uri.parse('${AppConstants.baseUrl}/products');
    final headers = await _ambilHeaders();
    final respon = await http.get(url, headers: headers);

    if (respon.statusCode == 200) {
      final isiRespon = jsonDecode(respon.body);
      if (isiRespon is List) {
        return List<Map<String, dynamic>>.from(isiRespon);
      } else if (isiRespon is Map && isiRespon['data'] != null) {
        return List<Map<String, dynamic>>.from(isiRespon['data']);
      }
      return [];
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<void> buatProduk(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products');
    final headers = await _ambilHeaders();
    final respon = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (respon.statusCode != 200 && respon.statusCode != 201) {
      throw Exception('Gagal membuat produk: ${respon.body}');
    }
  }

  Future<void> perbaruiProduk(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final headers = await _ambilHeaders();
    final respon = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (respon.statusCode != 200) {
      throw Exception('Gagal memperbarui produk: ${respon.body}');
    }
  }

  Future<void> hapusProduk(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final headers = await _ambilHeaders();
    final respon = await http.delete(url, headers: headers);

    if (respon.statusCode != 200 && respon.statusCode != 204) {
      throw Exception('Gagal menghapus produk: ${respon.body}');
    }
  }

  Future<void> ubahStatusProduk(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id/toggle-status');
    final headers = await _ambilHeaders();
    final respon = await http.patch(url, headers: headers);

    if (respon.statusCode != 200) {
      throw Exception('Gagal mengubah status produk: ${respon.body}');
    }
  }
}
