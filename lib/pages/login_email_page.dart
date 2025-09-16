import 'package:flutter/material.dart';

const _yumiGreen = Color(0xFF00A516);

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    Navigator.pushNamed(context, '/register', arguments: email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Ingresa tu e-mail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('E-mail', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'tucorreo@dominio.com',
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Ingresa tu correo';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s)) return 'Formato inválido';
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    final email = _emailCtrl.text.trim();
                    Navigator.pushNamed(context, '/login-password', arguments: email);
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
