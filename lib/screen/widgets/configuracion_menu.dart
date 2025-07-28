import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfiguracionMenuLateral extends StatelessWidget {
  final double widthFraction;
  const ConfiguracionMenuLateral({required this.widthFraction, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFraction,
      color: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
          const SizedBox(height: 20),
          const Text('MENÚ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _item(context, 'INVENTARIO', '/inventarioAdmin'),
          _item(context, 'REPORTES', '/reportes'),
          _item(context, 'VOLVER AL MENÚ', '/menuAdmin'),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.orange)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String label, String ruta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, ruta),
        child: Text(label, style: const TextStyle(color: Colors.orange, fontSize: 16)),
      ),
    );
  }
}

class ConfiguracionMenuDrawer extends StatelessWidget {
  const ConfiguracionMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: ConfiguracionMenuLateral(widthFraction: 1));
  }
}