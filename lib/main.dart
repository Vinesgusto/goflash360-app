import 'package:flutter/material.dart';

import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const GoFlash360App());
}

class GoFlash360App extends StatelessWidget {
  const GoFlash360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Flash 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF181717),
        ),
        fontFamily: 'Arial',
      ),
      home: const LoginScreen(),
    );
  }
}