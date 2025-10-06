import 'package:flutter/material.dart';
import 'email_password_screen.dart';

class EmailInputScreen extends StatefulWidget {
  const EmailInputScreen({super.key});

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const green = Color(0xFF0AD14C);
  static const bg = Color(0xFFF8F2F7);

  // Regex simple para email
  final _emailRx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool get _isValidEmail {
    final e = _emailCtrl.text.trim();
    return _emailRx.hasMatch(e);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      // Deja que el contenido se reajuste cuando sale el teclado
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Botón verde fijo abajo (se mueve con el teclado automáticamente)
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isValidEmail
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EmailPasswordScreen(email: _emailCtrl.text.trim()),
                ),
              );
            }
                : null,
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
              'Continuar',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),

      // Contenido scrollable para evitar overflow con teclado
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa tu e-mail',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  // NO hacemos setState dentro del validator
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Ingresa tu e-mail';
                    if (!_emailRx.hasMatch(value)) return 'E-mail inválido';
                    return null;
                  },
                  onChanged: (_) {
                    // Aquí sí podemos refrescar el botón sin romper el build
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'tu@email.com',
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
                ),
              ),
              const SizedBox(height: 300), // espacio para que no tape el teclado
            ],
          ),
        ),
      ),
    );
  }
}
