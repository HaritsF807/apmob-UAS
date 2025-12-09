import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart'; // Ensure this import path matches your project structure

class ApiService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer \$token',
    };
  }

  // Login
  Future<User> login(String username, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/login');
    
    // Debug logging
    print('🔵 LOGIN ATTEMPT');
    print('📍 URL: $url');
    print('👤 Username: $username');
    print('🔑 Password: ${password.replaceAll(RegExp(r'.'), '*')}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Assuming response structure: { "data": { "token": "...", "name": "...", ... } }
        final user = User.fromJson(body['data']);
        if (user.token != null) {
          await saveToken(user.token!);
          print('✅ Login successful! Token saved.');
        }
        return user;
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('💥 ERROR: $e');
      rethrow;
    }
  }

  // Get Users
  Future<List<User>> getUsers() async {
    final url = Uri.parse('${AppConstants.baseUrl}/users');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Create User
  Future<void> createUser(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Update User
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/\$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete User
  Future<void> deleteUser(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/\$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // =============================================
  // DASHBOARD ENDPOINTS
  // =============================================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('${AppConstants.baseUrl}/superadmin/dashboard');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<List<dynamic>> getSalesData() async {
    final url = Uri.parse('${AppConstants.baseUrl}/superadmin/sales-data');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? [];
    } else {
      throw Exception('Failed to load sales data');
    }
  }

  // =============================================
  // CATEGORY ENDPOINTS
  // =============================================
  
  Future<List<Map<String, dynamic>>> getCategories() async {
    final url = Uri.parse('${AppConstants.baseUrl}/categories');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // Handle both array response and { data: [] } structure
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      } else if (body is Map && body['data'] != null) {
        return List<Map<String, dynamic>>.from(body['data']);
      }
      return [];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/categories');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/categories/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/categories/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }

  // =============================================
  // PRODUCT ENDPOINTS
  // =============================================
  
  Future<List<Map<String, dynamic>>> getProducts() async {
    final url = Uri.parse('${AppConstants.baseUrl}/products');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      } else if (body is Map && body['data'] != null) {
        return List<Map<String, dynamic>>.from(body['data']);
      }
      return [];
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  Future<void> toggleProductStatus(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id/toggle-status');
    final headers = await _getHeaders();
    final response = await http.patch(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle product status: ${response.body}');
    }
  }

  // =============================================
  // TABLE ENDPOINTS
  // =============================================
  
  Future<List<Map<String, dynamic>>> getTables() async {
    final url = Uri.parse('${AppConstants.baseUrl}/tables');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      } else if (body is Map && body['data'] != null) {
        return List<Map<String, dynamic>>.from(body['data']);
      }
      return [];
    } else {
      throw Exception('Failed to load tables');
    }
  }

  Future<void> createTable(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tables');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create table: ${response.body}');
    }
  }

  Future<void> updateTable(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tables/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update table: ${response.body}');
    }
  }

  Future<void> deleteTable(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tables/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete table: ${response.body}');
    }
  }

  // =============================================
  // ORDER ENDPOINTS
  // =============================================
  
  Future<List<Map<String, dynamic>>> getOrders() async {
    final url = Uri.parse('${AppConstants.baseUrl}/orders/history');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      } else if (body is Map && body['data'] != null) {
        return List<Map<String, dynamic>>.from(body['data']);
      }
      return [];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/orders/$id/detail');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? body;
    } else {
      throw Exception('Failed to load order detail');
    }
  }
}
