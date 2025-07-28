import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_content.dart';

class MenuDrawer extends StatelessWidget {
  final FirebaseAuth auth;

  const MenuDrawer({required this.auth, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.orange, // Fondo naranja aplicado directamente
        child: MenuContent(auth: auth),
      ),
    );
  }
}