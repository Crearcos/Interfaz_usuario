import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const _yumiGreen = Color(0xFF00A516);

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});
  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _asking = false;

  Future<void> _askPermission() async {
    setState(() => _asking = true);
    final status = await Permission.locationWhenInUse.request();
    setState(() => _asking = false);

    if (status.isGranted) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/address', (_) => false);
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa el permiso desde Ajustes → Apps → Permisos')),
      );
      openAppSettings();
    } else {
      if (!mounted) return;
      // Si rechaza, aún así deja continuar a dirección (como en tu flujo puedes decidir)
      Navigator.pushNamedAndRemoveUntil(context, '/address', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Te ayudamos a encontrar tus\nproductos y locales cerca de ti',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _asking ? null : _askPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yumiGreen, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: _asking
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Permitir'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _asking ? null : () {
                    Navigator.pushNamedAndRemoveUntil(context, '/address', (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
