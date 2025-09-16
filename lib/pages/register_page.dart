import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _yumiGreen = Color(0xFF00A516);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _dobCtrl   = TextEditingController();

  String _gender = 'Femenino';
  bool _submitting = false;
  String? _error;
  bool _obscure = true;

  /// True si venimos de login social (Google/Facebook) y ya hay usuario autenticado no-password.
  bool _isSocial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Precarga email si llegó como argumento (p. ej., desde flujo previo)
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _emailCtrl.text.isEmpty) {
      _emailCtrl.text = arg;
    }

    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      // ¿Algún proveedor distinto de 'password'? => social
      _isSocial = current.providerData.any((p) => p.providerId != 'password');

      // Si trae email/displayName desde el proveedor, precarga
      if ((current.email ?? '').isNotEmpty) _emailCtrl.text = current.email!;
      final dn = (current.displayName ?? '').trim();
      if (dn.isNotEmpty && _nameCtrl.text.isEmpty && _lastCtrl.text.isEmpty) {
        final parts = dn.split(RegExp(r'\s+'));
        if (parts.isNotEmpty) _nameCtrl.text = parts.first;
        if (parts.length > 1) _lastCtrl.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isSocial) {
      // En registro por email/contraseña, valida coincidencia
      if (_passCtrl.text != _pass2Ctrl.text) {
        setState(() => _error = 'Las contraseñas no coinciden');
        return;
      }
    }

    setState(() { _submitting = true; _error = null; });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Caso 1: registro con email/password (no hay usuario autenticado)
      if (!_isSocial || user == null) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        user = cred.user;
      }

      // Actualiza displayName (útil tanto social como email/pass)
      await user?.updateDisplayName(
        '${_nameCtrl.text.trim()} ${_lastCtrl.text.trim()}'.trim(),
      );

      // Guarda/actualiza perfil en Firestore
      final uid = user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': _nameCtrl.text.trim(),
        'lastName' : _lastCtrl.text.trim(),
        'email'    : _emailCtrl.text.trim(),
        'gender'   : _gender,
        'birthDate': _dobCtrl.text.trim(), // si quieres, luego lo pasamos a Timestamp
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      // Flujo definido: después del registro ⇒ pedir permiso de ubicación
      Navigator.pushNamedAndRemoveUntil(context, '/loc-permission', (_) => false);
    } on FirebaseAuthException catch (e) {
      final msg = _mapError(e);
      setState(() => _error = msg);

      // UX: si el correo ya existe, ofrece ir a "Iniciar sesión"
      if (e.code == 'email-already-in-use' && mounted) {
        final go = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Este correo ya está registrado'),
            content: const Text('¿Quieres iniciar sesión con tu contraseña?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Iniciar sesión')),
            ],
          ),
        );
        if (go == true && mounted) {
          Navigator.pushNamed(context, '/login-password', arguments: _emailCtrl.text.trim());
        }
      }
    } catch (e) {
      setState(() => _error = 'No se pudo completar el registro: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'Este correo ya está registrado. Intenta iniciar sesión.';
      case 'invalid-email':        return 'Correo inválido.';
      case 'weak-password':        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      default:                     return e.message ?? 'Error de registro.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Termina el registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Completa tus datos', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            _label('Nombre (s)'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            _label('Apellido (s)'),
            TextFormField(
              controller: _lastCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            _label('Fecha de nacimiento (DD/MM/AAAA)'),
            TextFormField(
              controller: _dobCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                _DateSlashFormatter(), // ← inserta / automáticamente
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DD/MM/AAAA',
              ),
            ),
            const SizedBox(height: 12),

            _label('Género'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Femenino'),  selected: _gender == 'Femenino',  onSelected: (_) => setState(() => _gender = 'Femenino')),
                ChoiceChip(label: const Text('Masculino'), selected: _gender == 'Masculino', onSelected: (_) => setState(() => _gender = 'Masculino')),
                ChoiceChip(label: const Text('Otro'),       selected: _gender == 'Otro',      onSelected: (_) => setState(() => _gender = 'Otro')),
              ],
            ),
            const SizedBox(height: 16),

            _label('E-mail'),
            TextFormField(
              controller: _emailCtrl,
              readOnly: _isSocial, // ← solo bloquea en login social, no por tener texto
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Requerido';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s)) return 'Formato inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),

            if (!_isSocial) ...[
              _label('Contraseña'),
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
              const SizedBox(height: 12),

              _label('Confirmar contraseña'),
              TextFormField(
                controller: _pass2Ctrl,
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (v) => (v != _passCtrl.text) ? 'No coincide' : null,
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar cambios'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

/// Inserta automáticamente "/" para mostrar DD/MM/AAAA mientras se escribe.
/// Solo acepta dígitos y limita a 10 caracteres.
class _DateSlashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Mantén solo dígitos
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    String buf = '';
    for (int i = 0; i < digits.length; i++) {
      buf += digits[i];
      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buf += '/';
      }
    }

    return TextEditingValue(
      text: buf,
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}
