import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_login_screen.dart';
import 'email_input_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _green = Color(0xFF0AD14C);
  static const _fbBlue = Color(0xFF1877F2);

  bool _loading = false;

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      final res = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (res.status != LoginStatus.success) {
        _toast('Login cancelado o fallido (${res.status.name})');
        return;
      }

      final token = res.accessToken!;
      final cred = FacebookAuthProvider.credential(token.tokenString);
      await FirebaseAuth.instance.signInWithCredential(cred);
      // AuthGate te llevará al Home automáticamente
    } catch (e) {
      _toast('Error Facebook: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      // Abre selector de cuenta
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _toast('Login cancelado por el usuario');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken, // requiere SHA-1/SHA-256 en Firebase
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
      // AuthGate te llevará al Home automáticamente
    } catch (e) {
      _toast('Error Google: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Facebook
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _signInWithFacebook,
                        icon: const Icon(Icons.facebook, color: Colors.white),
                        label: const Text('Continue with Facebook',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fbBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Google
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.g_mobiledata, size: 28),
                            SizedBox(width: 8),
                            Text('Continue with Google',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Otros
                    _greenButton(
                      'Otro método de ingreso',
                          () => _toast('Abre selector de métodos'),
                    ),
                    const SizedBox(height: 12),
                    _greenButton(
                      'Número celular',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneLoginScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _greenButton(
                      'Correo electrónico',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmailInputScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _greenButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
