import 'package:flutter/material.dart';

class SupportMessageScreen extends StatefulWidget {
  final String presetMessage;
  const SupportMessageScreen({super.key, this.presetMessage = ''});

  @override
  State<SupportMessageScreen> createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  static const green = Color(0xFF0AD14C);
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.presetMessage.isNotEmpty) {
      _ctrl.text = widget.presetMessage;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu pedido llegó bien',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
              const SizedBox(height: 12),
              const Text('Contáctate con soporte',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Envía tu mensaje'),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Escribir...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí enviarías a tu backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mensaje enviado'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context); // volver
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Enviar',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
