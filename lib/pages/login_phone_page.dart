// lib/pages/login_phone_page.dart
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/phone_auth_controller.dart';

const _yumiGreen = Color(0xFF00A516);

class LoginPhonePage extends StatefulWidget {
  const LoginPhonePage({super.key});
  @override
  State<LoginPhonePage> createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  final _formKey = GlobalKey<FormState>();
  String _completeNumber = '';

  Future<void> _enviarCodigoSMS() async {
    // Garantiza que el número quede guardado aunque el usuario no edite
    _formKey.currentState?.save();
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<PhoneAuthController>();
    final ok = await vm.sendCode(
      _completeNumber,
      forceResendToken: vm.resendToken,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo enviar el código')),
      );
      return;
    }

    // Si hubo verificación automática ya hay usuario autenticado
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      Navigator.pushNamed(context, '/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PhoneAuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tu número de celular',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),

                IntlPhoneField(
                  initialCountryCode: 'EC',
                  onSaved: (p) => _completeNumber = p?.completeNumber ?? _completeNumber,
                  onChanged: (p) {
                    if (vm.error != null) vm.clearError(); // limpia errores al tipear
                    _completeNumber = p.completeNumber;     // +5939XXXXXXXX
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.black38, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  validator: (p) {
                    final n = (p?.number ?? '').trim();
                    final c = (p?.completeNumber ?? _completeNumber).trim();
                    if (n.isEmpty) return 'Ingresa tu número';
                    if (n.length < 8) return 'Número inválido';
                    if (c.isEmpty || !c.startsWith('+')) return 'Usa formato internacional (+código)';
                    return null;
                  },
                ),

                if (vm.error != null) ...[
                  const SizedBox(height: 8),
                  Text(vm.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56, width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () async {
                  FocusScope.of(context).unfocus();
                  await _enviarCodigoSMS();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yumiGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                child: vm.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Recibir código por SMS'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 72, width: double.infinity,
              child: ElevatedButton(
                onPressed: null, // WhatsApp aún no disponible
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                child: const Text('Recibir código por\nWhatsApp (no disponible)', textAlign: TextAlign.center),
              ),
            ),

            TextButton(
              onPressed: vm.isLoading || vm.resendToken == null
                  ? null
                  : () async {
                _formKey.currentState?.save();
                final ok = await context.read<PhoneAuthController>()
                    .sendCode(_completeNumber, forceResendToken: vm.resendToken);
                if (!mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.error ?? 'No se pudo reenviar el código')),
                  );
                }
              },
              child: const Text('Reenviar código'),
            ),
          ],
        ),
      ),
    );
  }
}
