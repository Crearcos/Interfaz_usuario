import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';
import '../profile/location_permission_screen.dart'; // 👈 luego de guardar

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  DateTime? _dob;
  String? _gender;
  bool _saving = false;

  static const bg = Color(0xFFF8F2F7);
  static const green = Color(0xFF0AD14C);

  @override
  void initState() {
    super.initState();
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) _nameCtrl.text = parts.first;
      if (parts.length > 1) _lastNameCtrl.text = parts.sublist(1).join(' ');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  bool get _isValidForm =>
      (_formKey.currentState?.validate() ?? false) &&
          _dob != null &&
          _gender != null;

  Future<void> _save() async {
    _formKey.currentState?.validate();
    if (!_isValidForm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nombre': _nameCtrl.text.trim(),
        'apellido': _lastNameCtrl.text.trim(),
        'genero': _gender,
        'dob': Timestamp.fromDate(_dob!),
        'dobText': _dobCtrl.text.trim(),
        'email': user.email,
        'photoURL': user.photoURL,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (_saving) return false;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Salir sin guardar?'),
        content: const Text('Perderás los cambios.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir')),
        ],
      ),
    );

    if (shouldExit == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return false;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
    return false;
  }

  void _handleBackButton() {
    _onWillPop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _handleBackButton,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Guardar cambios',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👇 Logo en la parte superior
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Image.asset(
                            'assets/logo.png', // asegúrate de tenerlo en assets
                            height: 60,
                          ),
                        ),
                      ),

                      const Text(
                        'Termina el registro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Completa tus datos',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      _label('Nombre (s)'),
                      _roundedField(
                        controller: _nameCtrl,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      _label('Apellido (s)'),
                      _roundedField(
                        controller: _lastNameCtrl,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      _label('Fecha de nacimiento'),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: _roundedField(
                            controller: _dobCtrl,
                            hint: 'DD/MM/AAAA',
                            validator: (_) =>
                            _dob == null ? 'Selecciona tu fecha' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _label('Género'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          _genderChip('Femenino',
                              selectedColor: const Color(0xFF8A00A8)),
                          _genderChip('Masculino'),
                          _genderChip('Otro'),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_saving,
                child: AnimatedOpacity(
                  opacity: _saving ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0)),
        ),
      ),
    );
  }

  Widget _genderChip(String value, {Color? selectedColor}) {
    final selected = _gender == value;
    return ChoiceChip(
      label: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _gender = value),
      selectedColor: selectedColor ?? Colors.black87,
      backgroundColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
