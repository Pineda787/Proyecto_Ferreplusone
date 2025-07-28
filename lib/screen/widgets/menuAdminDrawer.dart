import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menuAdminContent.dart';

class MenuAdminDrawer extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const MenuAdminDrawer({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MenuAdminContent(
        auth: auth,
        nombreUsuario: nombreUsuario,
        isLoading: isLoading,
      ),
    );
  }
}