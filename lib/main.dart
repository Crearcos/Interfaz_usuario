import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // usa tu google-services.json
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F2F7),

        // Configura tus fuentes globalmente
        fontFamily: 'Poppins',

        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          displayMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
          titleLarge: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
          labelLarge: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),

        // 👇 Opcional: personaliza AppBar y botones para usar la fuente también
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
