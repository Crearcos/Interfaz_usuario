import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class SupportMessageScreen extends StatefulWidget {
  const SupportMessageScreen({super.key, this.issue});
  final String? issue; // opcional: "Llegó fría", "Pedido demorado", etc.

  @override
  State<SupportMessageScreen> createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  final _msgCtrl = TextEditingController();
  static const green = Color(0xFF0AD14C);

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // TODO: aquí envías a tu backend/Firestore si corresponde.
    // Ejemplo:
    // await FirebaseFirestore.instance.collection('support_msgs').add({
    //   'issue': widget.issue,
    //   'message': text,
    //   'createdAt': FieldValue.serverTimestamp(),
    // });

    if (!mounted) return;

    // Confirmación + VOLVER (al HOME, no al pedido)
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mensaje enviado'),
        content: const Text('Gracias, nuestro equipo te contactará pronto.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // cierra el diálogo
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false, // limpia todo (no vuelve al pedido)
              );
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.issue == null || widget.issue!.isEmpty
        ? 'Escribir...'
        : '[${widget.issue}] Escribir...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu pedido llegó bien'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contáctate con soporte',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Envía tu mensaje'),
            const SizedBox(height: 8),
            TextField(
              controller: _msgCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _msgCtrl.text.trim().isEmpty ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Enviar',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
