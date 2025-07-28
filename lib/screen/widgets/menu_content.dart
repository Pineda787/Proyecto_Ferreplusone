import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuContent extends StatelessWidget {
  final FirebaseAuth auth;

  const MenuContent({required this.auth, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange, // Fondo naranja aplicado aquí
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
          const SizedBox(height: 20),
          const Text(
            'MENU',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texto blanco para mejor contraste
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('CREAR USUARIO'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacementNamed(context, '/home');
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
}