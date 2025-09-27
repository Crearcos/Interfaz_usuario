import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_completion_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        final user = authSnap.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _fetchProfile(user.uid),
          builder: (context, docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }

            if (docSnap.hasError) {
              _showError(context, "Error cargando perfil: ${docSnap.error}");
              return const ProfileCompletionScreen();
            }

            final data = docSnap.data?.data();
            if (data == null) {
              _showError(context, "Perfil no encontrado en Firestore");
              return const ProfileCompletionScreen();
            }

            final hasProfile =
                (data['nombre'] ?? '').toString().trim().isNotEmpty &&
                    (data['apellido'] ?? '').toString().trim().isNotEmpty &&
                    data['genero'] != null &&
                    (data['dob'] ?? '').toString().trim().isNotEmpty;

            return hasProfile
                ? const HomeScreen()
                : const ProfileCompletionScreen();
          },
        );
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProfile(String uid) {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    return ref.get().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        throw TimeoutException("Firestore timeout (8s)");
      },
    );
  }

  void _showError(BuildContext context, String msg) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
