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
    return Container(
      color: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
          const SizedBox(height: 20),
          const Text(
            'MENÚ ADMIN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _boton(context, 'INVENTARIO', '/inventarioAdmin'),
          _boton(context, 'REPORTES', '/reportes'),
          _boton(context, 'CONFIGURAR USUARIOS', '/configuracion'),
          const Spacer(),
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(nombreUsuario, style: const TextStyle(color: Colors.white)),
                  ],
                ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('SALIR'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _boton(BuildContext context, String label, String ruta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, ruta),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}