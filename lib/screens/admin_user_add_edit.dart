import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class UserFormScreen extends StatefulWidget {
  final User? user; // If null, it's Add mode. If set, it's Edit mode.

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? "");
    _usernameController = TextEditingController(text: widget.user?.username ?? "");
    _emailController = TextEditingController(text: widget.user?.email ?? "");
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Check password match if provided
    if (_passwordController.text.isNotEmpty && 
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        // Only include password if provided (for edit) or required (for create)
        if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
        if (widget.user == null) 'role_id': 'RL002', // Default Admin ID logic from Vue
      };

      if (widget.user == null) {
        // Create
        await _apiService.createUser(data);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully")),
          );
        }
      } else {
        // Update
        await _apiService.updateUser(widget.user!.id!, data);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User updated successfully")),
          );
        }
      }

      if (mounted) Navigator.pop(context, true); // Return true to trigger refresh
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: \${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Admin" : "Add Admin", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("e.g., John Doe"),
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Username"),
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration("e.g., johndoe123"),
                validator: (v) => v!.isEmpty ? "Username is required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Email Address"),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("e.g., john@example.com"),
                validator: (v) => v!.isEmpty || !v.contains('@') ? "Valid email is required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Password \${isEdit ? '(Leave blank to keep current)' : '*'}"),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration("••••••").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (!isEdit && v!.isEmpty) return "Password is required";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel("Confirm Password"),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration("••••••"),
                validator: (v) {
                   if (!isEdit && v!.isEmpty) return "Please confirm password";
                   return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColorValue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isEdit ? "Update Admin" : "Save Admin",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B6B6B), // Azure/Grey
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppConstants.primaryColorValue)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
