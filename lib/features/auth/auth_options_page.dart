// lib/features/auth/auth_options_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _yumiGreen = Color(0xFF00A516);

// Para Android normalmente NO necesitas clientId.
// Si más adelante soportas iOS/Web con el plugin nativo, ponlo aquí.
const _webClientId = ''; // 'TU_WEB_CLIENT_ID.apps.googleusercontent.com';

class AuthChoicePage extends StatefulWidget {
  const AuthChoicePage({super.key});
  @override
  State<AuthChoicePage> createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends State<AuthChoicePage> {
  bool _loading = false;

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
    );
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) Future.microtask(_goHome);
  }

  // ----------------- FACEBOOK -----------------
  Future<void> _facebook() async {
    setState(() => _loading = true);
    try {
      if (kIsWeb) {
        // Solo úsalo si ya configuraste Facebook para Web en Firebase y Facebook Developers
        await FirebaseAuth.instance.signInWithPopup(FacebookAuthProvider());
      } else {
        final result = await FacebookAuth.instance.login(
          permissions: const ['email', 'public_profile'],
          loginBehavior: LoginBehavior.nativeOnly, // en emulador podrías usar webOnly
        );
        if (result.status != LoginStatus.success || result.accessToken == null) {
          throw Exception('Inicio con Facebook cancelado o no disponible.');
        }
        final cred = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await FirebaseAuth.instance.signInWithCredential(cred);
      }
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Error de autenticación con Facebook.');
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ----------------- GOOGLE -----------------
  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      if (kIsWeb) {
        // WEB: usa el proveedor web directo de Firebase (no el plugin nativo)
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        // ANDROID: flujo con plugin nativo
        await GoogleSignIn.instance.initialize(
          serverClientId: _webClientId.isEmpty ? null : _webClientId,
        );
        final account = await GoogleSignIn.instance.authenticate();
        final tokens = await account.authentication; // v7: solo idToken
        final credential = GoogleAuthProvider.credential(idToken: tokens.idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Error de autenticación con Google.');
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

              // Si no configuraste Facebook para Web, puedes desactivar el botón en Web:
              _FbButton(disabled: _loading /* || kIsWeb */, onTap: _facebook),
              const SizedBox(height: 16),

              _GoogleButton(disabled: _loading, onTap: _google),
              const SizedBox(height: 16),

              _GreenButton(
                text: 'Número celular',
                onTap: _loading ? null : () => Navigator.pushNamed(context, '/phone'),
              ),
              const SizedBox(height: 16),

              _GreenButton(
                text: 'Correo electrónico',
                onTap: _loading ? null : () => Navigator.pushNamed(context, '/login-email'),
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
      height: 56, width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onTap,
        icon: const Icon(Icons.facebook, size: 22),
        label: const Text('Continuar con Facebook'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
          height: 56, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.g_mobiledata, size: 28),
              SizedBox(width: 8),
              Text(
                'Continuar con Google',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
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
      height: 56, width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _yumiGreen, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      ),
    );
  }
}
