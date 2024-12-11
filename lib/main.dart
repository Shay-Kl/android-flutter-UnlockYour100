import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // Set LoginScreen as the home
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}
