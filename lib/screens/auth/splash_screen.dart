import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_gate.dart'; // ajusta la ruta si tu AuthGate está en otro lado

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Muestra el splash 2.5s y navega al AuthGate
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0AD14C), // verde YumiFit
      body: Center(
        child: Image(
          image: AssetImage('assets/logo_splash.png'),
          width: 180, // ajusta tamaño si quieres
        ),
      ),
    );
  }
}
