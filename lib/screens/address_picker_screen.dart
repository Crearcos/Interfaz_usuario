import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class AddressPickerScreen extends StatefulWidget {
  final LatLng? initial; // opcional: posición inicial para centrar

  const AddressPickerScreen({super.key, this.initial});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  static const bg = Color(0xFFF8F2F7);
  static const green = Color(0xFF0AD14C);

  final _searchCtrl = TextEditingController();
  final MapController _mapCtrl = MapController();

  LatLng? _center;               // centro actual del mapa (selección)
  String? _readable;             // dirección legible
  bool _working = false;

  StreamSubscription<MapEvent>? _mapSub;

  @override
  void initState() {
    super.initState();
    _listenMapEvents();
    _bootstrap();
  }

  @override
  void dispose() {
    _mapSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _listenMapEvents() {
    _mapSub = _mapCtrl.mapEventStream.listen((event) async {
      // Cuando el usuario termina de mover el mapa, actualizamos centro + dirección
      if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
        final c = event.camera.center;
        setState(() => _center = c);
        _reverseGeocode(c);
      }
    });
  }

  Future<void> _bootstrap() async {
    if (widget.initial != null) {
      _setCenter(widget.initial!, animate: false);
      return;
    }
    // Fallback: intenta usar ubicación actual; si no, usa Quito
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        _setCenter(const LatLng(-0.1807, -78.4678), animate: false);
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        _setCenter(const LatLng(-0.1807, -78.4678), animate: false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      _setCenter(LatLng(pos.latitude, pos.longitude), animate: false);
    } catch (_) {
      _setCenter(const LatLng(-0.1807, -78.4678), animate: false);
    }
  }

  Future<void> _setCenter(LatLng p, {bool animate = true, double? zoom}) async {
    setState(() => _center = p);
    final z = zoom ?? _mapCtrl.camera.zoom.takeIf((v) => v > 0) ?? 16.0;
    _mapCtrl.move(p, z);
    _reverseGeocode(p);
  }

  Future<void> _reverseGeocode(LatLng p) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=json&lat=${p.latitude}&lon=${p.longitude}&zoom=18&addressdetails=1',
      );
      final resp = await http.get(url, headers: {
        // Usa un UA con contacto real si vas a producción
        'User-Agent': 'interfaz_usuario/1.0 (contacto@example.com)'
      });
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() => _readable = data['display_name']);
      }
    } catch (_) {
      // silencioso
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      _snack('Escribe una dirección para buscar.');
      return;
    }
    setState(() => _working = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?format=json&limit=1&q=${Uri.encodeComponent(q)}',
      );
      final resp = await http.get(url, headers: {
        'User-Agent': 'interfaz_usuario/1.0 (contacto@example.com)'
      });
      if (resp.statusCode == 200) {
        final List list = jsonDecode(resp.body);
        if (list.isEmpty) {
          _snack('No se encontró esa dirección.');
        } else {
          final o = list.first;
          final p = LatLng(double.parse(o['lat']), double.parse(o['lon']));
          await _setCenter(p, zoom: 17);
          setState(() => _readable = o['display_name']);
        }
      } else {
        _snack('Error de búsqueda: ${resp.statusCode}');
      }
    } catch (e) {
      _snack('Error buscando: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _myLocation() async {
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        _snack('Activa el GPS.');
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        _snack('Permiso de ubicación denegado.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      await _setCenter(LatLng(pos.latitude, pos.longitude), zoom: 17);
    } catch (e) {
      _snack('No se pudo obtener tu ubicación: $e');
    }
  }

  Future<void> _save() async {
    if (_center == null) {
      _snack('Selecciona una ubicación.');
      return;
    }
    setState(() => _working = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'address': {
            'text': _readable,
            'searchText': _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
            'lat': _center!.latitude,
            'lng': _center!.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
            'source': 'nominatim',
          }
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (r) => false,
      );
    } catch (e) {
      _snack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _working ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: const Text(
              'Guardar dirección',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset('assets/logo.png', height: 48)),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingresa tu dirección',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            hintText: 'Buscar dirección',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _working ? null : _search,
                        icon: const Icon(Icons.search, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _working ? null : _myLocation,
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, size: 28),
                        SizedBox(width: 10),
                        Text('Mi ubicación actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // --- Mapa con pin fijo al centro ---
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_center == null)
                            const Center(child: CircularProgressIndicator())
                          else
                            FlutterMap(
                              mapController: _mapCtrl,
                              options: MapOptions(
                                initialCenter: _center!,
                                initialZoom: 16,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.interfaz_usuario',
                                ),
                              ],
                            ),
                          const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ],
                      ),
                    ),
                  ),
                  if (_readable != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _readable!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
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

extension<T extends num> on T {
  T? takeIf(bool Function(T v) test) => test(this) ? this : null;
}
