import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

const _yumiGreen = Color(0xFF00A516);

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});
  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _searchCtrl = TextEditingController();
  Position? _pos;
  String? _resolved;
  bool _busy = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() { _busy = true; _resolved = null; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sin permiso de ubicación')),
          );
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _pos = pos;

      final placemarks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _resolved = [
          if ((p.street ?? '').isNotEmpty) p.street,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
          if ((p.locality ?? '').isNotEmpty) p.locality,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
          if ((p.country ?? '').isNotEmpty) p.country,
        ].whereType<String>().join(', ');
        _searchCtrl.text = _resolved!;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener ubicación: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty && _pos == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _yumiGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Text('Termina de llenar el formulario', style: TextStyle(color: Colors.white, fontSize: 18)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver', style: TextStyle(color: Colors.white)))
          ],
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'address': text.isNotEmpty ? text : (_resolved ?? ''),
        'lat': _pos?.latitude,
        'lng': _pos?.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la dirección: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresa tu dirección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buscar dirección'),
            const SizedBox(height: 6),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar dirección',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Mi ubicación actual'),
              onTap: _busy ? null : _useCurrentLocation,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Mapa (placeholder)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _busy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar dirección'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
