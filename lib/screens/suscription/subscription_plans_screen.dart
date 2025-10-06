import 'package:flutter/material.dart';
import 'subscription_detail_screen.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  static const purple = Color(0xFF6A1B9A);
  static const green = Color(0xFF0AD14C);
  static const yellow = Color(0xFFFFDD33);
  static const bg = Color(0xFFF8F2F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                // Mini “logo” placeholder
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Con YumiFit Plus\nahorras',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _planCard(
              context,
              title: 'YUMIFIT',
              priceText: r'$4,99',
              highlightPoints: const [
                '+ Envíos gratis',
                '+ Descuentos exclusivos',
              ],
              color: yellow,
              onSubscribe: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionDetailScreen(
                      planName: 'YumiFit Plus',
                      price: 4.99,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _planCard(
              context,
              title: 'YUMIFIT',
              priceText: r'$47,90',
              highlightPoints: const [
                '+ Envíos gratis',
                '+ Descuentos exclusivos',
                '+ Cita con tu nutricionista',
              ],
              color: yellow,
              onSubscribe: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionDetailScreen(
                      planName: 'YumiFit Plus Anual',
                      price: 47.90,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Bottom nav fake (si quieres mantener consistencia visual)
      bottomNavigationBar: SizedBox(height: 0),
    );
  }

  Widget _planCard(
      BuildContext context, {
        required String title,
        required String priceText,
        required List<String> highlightPoints,
        required Color color,
        required VoidCallback onSubscribe,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Teléfono mock a la derecha (simple rectángulo)
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            child: Container(
              width: 92,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 3),
              ),
              alignment: Alignment.center,
              child: const Text('YumiFit',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 120, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(priceText,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 8),
                ...highlightPoints
                    .map((p) => Text(p,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)))
                    .toList(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Suscribirse',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
