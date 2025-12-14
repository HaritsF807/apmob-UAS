import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['data']['role_id'] != 'RL001') {
          return {
            'success': false,
            'message': 'Hanya Super Admin yang dapat login',
          };
        }

        return {
          'success': true,
          'token': data['data']['token'],
          'name': data['data']['name'],
          'role': data['data']['role'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: ${e.toString()}',
      };
    }
  }

  // ambil token user dari storage buat keperluan authentikasi
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ambil semua data produk dari backend
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Gagal mengambil produk');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ambil semua kategori produk yang ada
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Gagal mengambil kategori');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // bikin produk baru, kirim semua data ke backend
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String categoryId,
    required double price,
    required String status,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'category_id': categoryId,
          'price': price.toString(),
          'description': '-',
          'status': status,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Produk berhasil ditambahkan',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal menambahkan produk',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // update data produk yang udah ada
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required String categoryId,
    required double price,
    required String status,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'category_id': categoryId,
          'price': price.toString(),
          'description': '-',
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Produk berhasil diupdate',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal mengupdate produk',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // hapus produk berdasarkan id
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final token = await _getToken();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Produk berhasil dihapus',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal menghapus produk',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // hapus semua data user dari storage buat logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
  }
}







