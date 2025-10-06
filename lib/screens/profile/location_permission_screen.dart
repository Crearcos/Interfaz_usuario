import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'address_picker_screen.dart';
import '../home/home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  static const green = Color(0xFF0AD14C);
  static const bg = Color(0xFFF8F2F7);

  bool _working = false;

  // Intenta obtener la ubicación sin colgarse (ANR): lastKnown -> current con timeout
  Future<Position?> _safeGetPosition() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
    } catch (_) {}

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _requestPermissionAndGo() async {
    setState(() => _working = true);
    try {
      // 1) Servicio de ubicación activo
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Activa el GPS para continuar');
        setState(() => _working = false);
        return;
      }

      // 2) Permisos
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _snack('Permiso denegado');
        setState(() => _working = false);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Permiso denegado permanentemente. Ve a Ajustes > Apps > Permisos.');
        setState(() => _working = false);
        return;
      }

      // 3) Posición con fallbacks (evita cuelgues del emulador)
      final pos = await _safeGetPosition();
      final initialCenter = (pos != null)
          ? LatLng(pos.latitude, pos.longitude)
          : const LatLng(-0.1807, -78.4678); // Quito como fallback

      if (!mounted) return;

      // 4) Navega SOLO al selector de dirección (aquí no guardamos nada)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AddressPickerScreen(initial: initialCenter),
        ),
      );
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _skip() {
    // Si el usuario no quiere compartir la ubicación, lo dejas pasar
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (r) => false,
    );
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset('assets/logo.png', height: 60),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Te ayudamos a encontrar tus\nproductos y locales cerca de ti',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Ilustración
                  const Center(
                    child: Icon(Icons.location_on, size: 140, color: Colors.redAccent),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    '¿Permites acceder a tu\nubicación?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  // Botón Permitir
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _working ? null : _requestPermissionAndGo,
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
                        'Permitir',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón Rechazar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _working ? null : _skip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBFC3CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_working)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
