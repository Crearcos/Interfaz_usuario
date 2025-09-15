import 'package:flutter/material.dart';

class OtherMethodsPage extends StatelessWidget {
  const OtherMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Otros métodos')),
      body: const Center(child: Text('Apple / X / etc.')),
    );
  }
}
