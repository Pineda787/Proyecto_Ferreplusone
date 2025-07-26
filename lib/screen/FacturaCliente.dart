import 'dart:convert';
import 'dart:html' as html; // Para Flutter Web
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacturaClienteScreen extends StatelessWidget {
  const FacturaClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: Row(
        children: [
          _buildMenuLateral(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FACTURAS EMITIDAS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('facturas')
                          .where('clienteId', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No hay facturas disponibles.'),
                          );
                        }

                        final facturas = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: facturas.length,
                          itemBuilder: (context, index) {
                            final factura =
                                facturas[index].data() as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  'Factura #${factura['numero'] ?? 'N/A'}',
                                ),
                                subtitle: Text(
                                  'Total: L. ${factura['total'] ?? 0}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(factura['fecha'] ?? 'Sin fecha'),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () {
                                        _descargarFacturaWeb(factura);
                                      },
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

  void _descargarFacturaWeb(Map<String, dynamic> factura) {
    final detalles = factura['detalles'] as List<dynamic>? ?? [];

    // Construir contenido con detalles
    String contenido =
        '''
FACTURA
-------

Número: ${factura['numero'] ?? 'N/A'}
Fecha: ${factura['fecha'] ?? 'Sin fecha'}
Total: L. ${factura['total'] ?? 0}

DETALLES:
''';

    if (detalles.isEmpty) {
      contenido += 'No hay productos.\n';
    } else {
      for (var item in detalles) {
        contenido +=
            '${item['nombre']} - Cantidad: ${item['cantidad']} - Precio unitario: L. ${item['precio']} - Subtotal: L. ${item['precio'] * item['cantidad']}\n';
      }
    }

    final bytes = utf8.encode(contenido);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "factura_${factura['numero'] ?? 'nueva'}.txt")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Widget _buildMenuLateral(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      color: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
          const SizedBox(height: 20),
          const Text(
            'CLIENTE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuButton(context, 'INVENTARIO', '/inventario'),
          _buildMenuButton(context, 'VENTAS', '/ventas'),
          _buildMenuButton(context, 'FACTURA', '/factura'),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              'CERRAR SESIÓN',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        child: Text(text, style: const TextStyle(color: Colors.orange)),
      ),
    );
  }
}
