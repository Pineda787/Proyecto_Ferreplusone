import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuAdminContent extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const MenuAdminContent({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
        const SizedBox(height: 20),
        const Text('MENU', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildMenuButton(context, 'INVENTARIO', '/inventarioAdmin'),
        _buildMenuButton(context, 'REPORTES', '/reportes'),
        _buildMenuButton(context, 'CONFIGURACIÓN DE USUARIOS', '/configuracion'),
        const Spacer(),
        isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(nombreUsuario, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          onPressed: () async {
            await auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.orange, fontSize: 16)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        child: Text(label, style: const TextStyle(color: Colors.orange, fontSize: 16)),
      ),
    );
  }
}