import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../pages/login_email_page.dart';
import '../../pages/login_phone_page.dart';
import '../../pages/other_methods_page.dart';
import '../home/home_page.dart';

const _yumiGreen = Color(0xFF00A516);
const _fbBlue = Color(0xFF1877F2);
const _webClientId = 'TU_WEB_CLIENT_ID.apps.googleusercontent.com';

class AuthChoicePage extends StatefulWidget {
  const AuthChoicePage({super.key});
  @override
  State<AuthChoicePage> createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends State<AuthChoicePage> {
  bool _loading = false;

  void _err(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      final r = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.nativeOnly,
      );
      if (r.status != LoginStatus.success || r.accessToken == null) {
        throw Exception('Necesitas la app de Facebook instalada y abierta.');
      }
      final cred =
      FacebookAuthProvider.credential(r.accessToken!.tokenString);
      await FirebaseAuth.instance.signInWithCredential(cred);
      if (!mounted) return;
      _goHome();
    } catch (e) {
      _err(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      final account = await GoogleSignIn.instance.authenticate();
      if (account == null) throw Exception('Inicio con Google cancelado.');

      final auth = await account.authentication; // solo idToken disponible
      final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      _err(e.message ?? 'Error de autenticación.');
    } catch (e) {
      _err(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }



  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              SizedBox(height: h * 0.25),
              _FbButton(disabled: _loading, onTap: _signInWithFacebook),
              const SizedBox(height: 16),
              _GoogleButton(disabled: _loading, onTap: _google),
              const SizedBox(height: 16),
              _GreenButton(
                text: 'Otro método de ingreso',
                onTap: _loading
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OtherMethodsPage()),
                ),
              ),
              const SizedBox(height: 16),
              _GreenButton(
                text: 'Número celular',
                onTap: _loading
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginPhonePage()),
                ),
              ),
              const SizedBox(height: 16),
              _GreenButton(
                text: 'Correo electrónico',
                onTap: _loading
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginEmailPage()),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FbButton extends StatelessWidget {
  final bool disabled;
  final VoidCallback onTap;
  const _FbButton({required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onTap,
        icon: const Icon(Icons.facebook, size: 22),
        label: const Text('Continue with Facebook'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _fbBlue,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool disabled;
  final VoidCallback onTap;
  const _GoogleButton({required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/google_logo.png',
                  width: 22, height: 22),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _GreenButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _yumiGreen,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      ),
    );
  }
}
