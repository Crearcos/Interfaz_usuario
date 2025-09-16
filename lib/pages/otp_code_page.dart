// lib/pages/otp_code_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../features/auth/phone_auth_controller.dart';

class OtpCodePage extends StatefulWidget {
  const OtpCodePage({super.key});

  @override
  State<OtpCodePage> createState() => _OtpCodePageState();
}

class _OtpCodePageState extends State<OtpCodePage> {
  final _otpCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
      );
      return;
    }

    final vm = context.read<PhoneAuthController>();
    setState(() => _submitting = true);

    try {
      await vm.confirmCode(code);
      if (!mounted) return;
      // Éxito: entra a la app
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (_) {
      if (!mounted) return;
      // Muestra mensaje amistoso del controller (o genérico)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Código inválido o expirado')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PhoneAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Código de verificación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa el código SMS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      prefixIcon: Icon(Icons.verified),
                    ),
                    onSubmitted: (_) => _confirm(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_submitting || vm.isLoading) ? null : _confirm,
                      child: (_submitting || vm.isLoading)
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Confirmar'),
                    ),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 8),
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    child: const Text('¿Ingresaste mal el número? Cambiar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
