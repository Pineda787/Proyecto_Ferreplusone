import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_cliente_content.dart';

class MenuClienteDrawer extends StatelessWidget {
  final FirebaseAuth auth;
  final String nombreUsuario;
  final bool isLoading;

  const MenuClienteDrawer({
    required this.auth,
    required this.nombreUsuario,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MenuClienteContent(
        auth: auth,
        nombreUsuario: nombreUsuario,
        isLoading: isLoading,
      ),
    );
  }
}