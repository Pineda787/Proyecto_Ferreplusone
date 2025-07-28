import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/menuAdminContent.dart';
import 'widgets/menuAdminDrawer.dart';

class MenuAdmin extends StatefulWidget {
  const MenuAdmin({super.key});

  @override
  _MenuAdminState createState() => _MenuAdminState();
}

class _MenuAdminState extends State<MenuAdmin> {
  String _nombreUsuario = '';
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _cargarNombreUsuario(user.uid);
      }
    });
  }

  void _cargarNombreUsuario(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      setState(() {
        _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nombreUsuario = 'Error al cargar';
        _isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  return Scaffold(
    appBar: isMobile ? AppBar(title: const Text('Panel Administrativo')) : null,
    drawer: isMobile
        ? MenuAdminDrawer(
            auth: FirebaseAuth.instance,
            nombreUsuario: _nombreUsuario,
            isLoading: _isLoading,
          )
        : null,
    body: Row(
      children: [
        if (!isMobile)
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            color: Colors.orange,
            child: MenuAdminDrawer(
              auth: FirebaseAuth.instance,
              nombreUsuario: _nombreUsuario,
              isLoading: _isLoading,
            ),
          ),
        Expanded(child: buildMainContent()), // Aquí muestras el contenido principal
      ],
    ),
  );
}




  Widget buildMainContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Image.network(
              'https://i.imgur.com/qxRSDQR.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.6)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bienvenido, $_nombreUsuario',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Desde aquí puedes gestionar inventario, reportes y configurar los usuarios del sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, route);
        },
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}