import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _yumiGreen = Color(0xFF00A516);

class LoginPasswordPage extends StatefulWidget {
  const LoginPasswordPage({super.key});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _obscure = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _emailCtrl.text.isEmpty) {
      _emailCtrl.text = arg;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _submitting = true; _error = null; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e));
    } catch (e) {
      setState(() => _error = 'No se pudo iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Correo inválido.';
      case 'user-disabled': return 'Usuario deshabilitado.';
      case 'user-not-found': return 'Usuario no encontrado.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      default: return e.message ?? 'Error de autenticación.';
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo para recuperar la contraseña.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un enlace para restablecer la contraseña')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el correo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text('Ingresar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('E-mail'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Ingresa tu correo';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s)) return 'Formato inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('Contraseña'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _resetPassword, child: const Text('¿Olvidaste tu contraseña?')),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Ingresar', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
