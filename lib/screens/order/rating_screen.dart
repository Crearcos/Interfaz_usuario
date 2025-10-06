import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  static const purple = Color(0xFF6A1B9A);
  int _rating = 0;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
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
              const Text('Dejar tu valoración',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  final filled = idx <= _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = idx),
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 32,
                      color: filled ? Colors.amber : Colors.black54,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text('Observación'),
              const SizedBox(height: 6),
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
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
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí guardarías rating + comentario
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Volver',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
