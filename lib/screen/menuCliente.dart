import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/menu_cliente_content.dart';
import 'widgets/menu_cliente_drawer.dart';

class MenuCliente extends StatefulWidget {
  const MenuCliente({super.key});

  @override
  _MenuClienteState createState() => _MenuClienteState();
}

class _MenuClienteState extends State<MenuCliente> {
  String _nombreUsuario = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _cargarNombreUsuario(user.uid);
      }
    });
  }

  void _cargarNombreUsuario(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      setState(() {
        _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario';
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _nombreUsuario = 'Error al cargar';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('Ferretería OnePlus'),
                ),
          drawer: isDesktop
              ? null
              : MenuClienteDrawer(
                  auth: FirebaseAuth.instance,
                  nombreUsuario: _nombreUsuario,
                  isLoading: _isLoading,
                ),
          body: isDesktop
              ? Row(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.25,
                      child: MenuClienteContent(
                        auth: FirebaseAuth.instance,
                        nombreUsuario: _nombreUsuario,
                        isLoading: _isLoading,
                      ),
                    ),
                    Expanded(child: _buildPanelCentral()),
                  ],
                )
              : _buildPanelCentral(),
        );
      },
    );
  }

  Widget _buildPanelCentral() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network('https://i.imgur.com/qxRSDQR.jpg', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.6)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nombreUsuario,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecciona una opción del menú para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}