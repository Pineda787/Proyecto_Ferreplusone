import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuClienteContent extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const MenuClienteContent({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      color: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
          const SizedBox(height: 20),
          const Text('MENÚ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _boton(context, 'INVENTARIO', '/inventarioCliente'),
          _boton(context, 'VENTA Y CARRITO', '/ventaCarrito'),
          _boton(context, 'FACTURAS', '/facturas'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
            child: const Text('CERRAR SESIÓN'),
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
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
        child: Text(label),
      ),
    );
  }
}