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
}
