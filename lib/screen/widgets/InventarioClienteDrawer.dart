import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventarioClienteDrawer extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const InventarioClienteDrawer({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 160),
          const SizedBox(height: 10),
          const Text(
            'FERRETERÍA ONEPLUS',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white, thickness: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  'MENÚ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuItem(Icons.inventory, 'INVENTARIO', context, '/inventarioCliente'),
                _buildMenuItem(Icons.shopping_cart, 'VENTA Y CARRITO', context, '/ventaCarrito'),
                _buildMenuItem(Icons.receipt, 'FACTURAS', context, '/facturas'),
                _buildMenuItem(Icons.arrow_back, 'VOLVER AL MENÚ', context, '/menuCliente'),
              ],
            ),
          ),
          const Divider(color: Colors.white, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nombreUsuario,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                await auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, BuildContext context, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.orange),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}