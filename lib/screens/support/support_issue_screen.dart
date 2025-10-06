import 'package:flutter/material.dart';
import 'support_message_screen.dart';

class SupportIssueScreen extends StatelessWidget {
  const SupportIssueScreen({super.key});

  static const green = Color(0xFF0AD14C);

  void _go(BuildContext context, String preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportMessageScreen(issue: preset),
      ),
    );
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
              // mini header
              const SizedBox(height: 6),
              const Text(
                'Tu pedido llegó bien',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: 16),
              _btn(context, 'Llegó fría', () => _go(context, 'Mi comida llegó fría')),
              const SizedBox(height: 12),
              _btn(context, 'Pedido demorado', () => _go(context, 'Mi pedido llegó tarde')),
              const SizedBox(height: 12),
              _btn(context, 'No es mi pedido', () => _go(context, 'Recibí un pedido equivocado')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
