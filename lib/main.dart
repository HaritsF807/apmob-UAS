import 'package:flutter/material.dart';
import 'Tampilan/auth_login.dart';
// import 'screens/admin_user_list.dart'; // Can import if logical check for auth is added in main

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tama Coffee Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        fontFamily: 'Poppins', // Assuming you add the font assets
      ),
      home: const LoginScreen(),
    );
  }
}
