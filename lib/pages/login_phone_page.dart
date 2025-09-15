import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_code_page.dart';

const _yumiGreen = Color(0xFF00A516);

class LoginPhonePage extends StatefulWidget {
  const LoginPhonePage({super.key});
  @override
  State<LoginPhonePage> createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  final _formKey = GlobalKey<FormState>();
  String _completeNumber = '';
  String _display = '';
  bool _sending = false;
  int? _resendToken;

  Future<void> _enviarCodigo({required String via}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _completeNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (cred) async {
          // Autoverificación en algunos dispositivos
          await FirebaseAuth.instance.signInWithCredential(cred);
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Error'), behavior: SnackBarBehavior.floating),
          );
        },
        codeSent: (verificationId, resendToken) {
          _resendToken = resendToken;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpCodePage(
                verificationId: verificationId,
                phoneLabel: _display,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const Text('Ingresa tu número de celular', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                IntlPhoneField(
                  initialCountryCode: 'EC',
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
                  onChanged: (p) {
                    _completeNumber = p.completeNumber;
                    _display = '+${p.countryCode} ${p.number}';
                  },
                  validator: (p) {
                    final n = (p?.number ?? '').trim();
                    if (n.isEmpty) return 'Ingresa tu número';
                    if (n.length < 8) return 'Número inválido';
                    return null;
                  },
                ),
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
                onPressed: _sending ? null : () => _enviarCodigo(via: 'SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Recibir código por SMS'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72, width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : () => _enviarCodigo(via: 'WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                child: const Text('Recibir código por\nWhatsApp', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
