import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'venta_y_carrito_content.dart';

class VentaYCarritoDrawer extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const VentaYCarritoDrawer({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.orange,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          Image.network('https://i.imgur.com/CK31nrT.png', height: 220),
          const SizedBox(height: 20),
          const Text(
            'MENÚ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuButton(context, 'INVENTARIO', '/inventarioCliente'),
          _buildMenuButton(context, 'VENTA Y CARRITO', '/ventaCarrito'),
          _buildMenuButton(context, 'FACTURAS', '/facturas'),
          _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuCliente'),
          const Divider(height: 40, color: Colors.white),
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(nombreUsuario, style: const TextStyle(color: Colors.white)),
                  ],
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'CERRAR SESIÓN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}