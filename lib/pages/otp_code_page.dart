import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/home/home_page.dart';

class OtpCodePage extends StatefulWidget {
  final String verificationId;
  final String phoneLabel;
  const OtpCodePage({super.key, required this.verificationId, required this.phoneLabel});

  @override
  State<OtpCodePage> createState() => _OtpCodePageState();
}

class _OtpCodePageState extends State<OtpCodePage> {
  final _nodes = List.generate(6, (_) => FocusNode());
  final _ctrs  = List.generate(6, (_) => TextEditingController());
  bool _verifying = false;

  @override
  void dispose() {
    for (final n in _nodes) n.dispose();
    for (final c in _ctrs) c.dispose();
    super.dispose();
  }

  String get _code => _ctrs.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length != 6) return;
    setState(() => _verifying = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Código inválido')),
      );
      for (final c in _ctrs) c.clear();
      _nodes.first.requestFocus();
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Widget _circleBox(int i) {
    return SizedBox(
      width: 56, height: 56,
      child: TextField(
        controller: _ctrs[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Colors.black87, width: 1.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Colors.black87, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < _nodes.length - 1) {
            _nodes[i + 1].requestFocus();
          } else if (v.isEmpty && i > 0) {
            _nodes[i - 1].requestFocus();
          }
          if (_code.length == 6) _verify();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Ingresa el código que se envió', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('A tu número celular ${widget.phoneLabel}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _circleBox(0), const SizedBox(width: 14),
                  _circleBox(1), const SizedBox(width: 14),
                  _circleBox(2), const SizedBox(width: 14),
                  _circleBox(3), const SizedBox(width: 14),
                  _circleBox(4), const SizedBox(width: 14),
                  _circleBox(5),
                ],
              ),
              if (_verifying) const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
