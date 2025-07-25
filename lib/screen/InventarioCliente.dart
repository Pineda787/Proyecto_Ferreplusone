import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventarioClienteScreen extends StatefulWidget {
  const InventarioClienteScreen({super.key});

  @override
  State<InventarioClienteScreen> createState() => _InventarioClienteScreenState();
}

class _InventarioClienteScreenState extends State<InventarioClienteScreen> {
  String _nombreUsuario = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        final data = doc.data();
        final rol = data?['rol'];
        if (rol != 'cliente') {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _nombreUsuario = data?['nombre'] ?? 'Cliente';
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🟧 Panel lateral estilo cliente
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            color: Colors.orange,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
                const SizedBox(height: 20),
                Text('MENU', style: menuTextStyle),
                const SizedBox(height: 30),
                _buildMenuButton(context, 'INVENTARIO', '/inventario'),
                _buildMenuButton(context, 'VENTAS', '/ventas'),
                _buildMenuButton(context, 'FACTURA', '/factura'),
                const Spacer(),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(_nombreUsuario, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: menuButtonStyle,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('CERRAR SESIÓN', style: menuButtonText),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 🛒 Panel principal con inventario
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INVENTARIO DE PRODUCTOS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No hay productos disponibles.'));
                        }

                        final productos = snapshot.data!.docs;
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final data = productos[index].data() as Map<String, dynamic>;
                            return Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        data['ImagenURL'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['NombreProducto'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Stock: ${data['Stock']}',
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Botón de menú lateral
  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: menuButtonStyle,
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        child: Text(label, style: menuButtonText),
      ),
    );
  }

  // 🎨 Estilos visuales
  final TextStyle menuTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  final TextStyle menuButtonText = const TextStyle(
    color: Colors.orange,
    fontSize: 16,
  );
}