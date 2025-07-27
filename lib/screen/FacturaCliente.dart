import 'dart:convert';
import 'dart:html' as html; // Flutter Web
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FacturaClienteScreen extends StatefulWidget {
  const FacturaClienteScreen({super.key});

  @override
  State<FacturaClienteScreen> createState() => _FacturaClienteScreenState();
}

class _FacturaClienteScreenState extends State<FacturaClienteScreen> {
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

  void _descargarFacturaWeb(Map<String, dynamic> factura) {
    final detalles = factura['detalles'] as List<dynamic>? ?? [];

    final fechaFormateada = factura['fecha'] is Timestamp
      ? DateFormat('dd/MM/yyyy').format((factura['fecha'] as Timestamp).toDate())
      : factura['fecha'] is String
          ? factura['fecha']
          : 'Sin fecha';

    String contenido = '''
FACTURA
-------

Número: ${factura['numero'] ?? 'N/A'}
Fecha: $fechaFormateada
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

  Future<void> _guardarFacturaReal(Map<String, dynamic> productos, double total) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final nuevaFactura = {
      'numero': 'F${DateTime.now().millisecondsSinceEpoch}',
      'fecha': DateTime.now(),
      'total': total,
      'clienteId': uid,
      'clienteNombre': _nombreUsuario,
      'usuarioQueFacturó': uid,
      'esPrueba': false, // ✅ facturas válidas
      'detalles': productos.entries.map((e) => {
        'nombre': e.key,
        'cantidad': e.value['cantidad'],
        'precio': e.value['precio'],
      }).toList(),
    };

    try {
      await FirebaseFirestore.instance.collection('facturas').add(nuevaFactura);
      print('✅ Factura guardada correctamente');
    } catch (e) {
      print('❌ Error al guardar la factura: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: Row(
        children: [
          // 🟧 Panel lateral
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

          // 🧾 Panel principal
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FACTURAS EMITIDAS',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                        .collection('facturas')
                        .where('clienteId', isEqualTo: uid)
                        .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No hay facturas disponibles.'));
                        }

                        final facturas = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: facturas.length,
                          itemBuilder: (context, index) {
                            final factura = facturas[index].data() as Map<String, dynamic>;
                            final fechaFormateada = factura['fecha'] is Timestamp
                              ? DateFormat('dd/MM/yyyy').format((factura['fecha'] as Timestamp).toDate())
                              : factura['fecha'] is String
                                  ? factura['fecha']
                                  : 'Sin fecha';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Factura #${factura['numero'] ?? 'N/A'}'),
                                subtitle: Text('Total: L. ${factura['total'] ?? 0}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(fechaFormateada),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () => _descargarFacturaWeb(factura),
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