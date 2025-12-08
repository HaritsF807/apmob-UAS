class User {
  final String? id; // Changed from int? to String? to handle "US003" format
  final String name;
  final String username;
  final String email;
  final String? role;
  final String? status;
  final String? token;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.role,
    this.status,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(), // Convert to String safely
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] is Map ? json['role']['name'] : json['role'], // Handle possibly nested role object
      status: json['status'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'status': status,
    };
  }
}
