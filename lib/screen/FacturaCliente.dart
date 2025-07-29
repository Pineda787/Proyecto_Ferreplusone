import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'widgets/FacturasClienteContent.dart';
import 'widgets/FacturasClienteDrawer.dart';


class FacturaClienteScreen extends StatefulWidget {


  const FacturaClienteScreen({super.key});

  @override
  State<FacturaClienteScreen> createState() => _FacturaClienteScreenState();
}

class _FacturaClienteScreenState extends State<FacturaClienteScreen> {
  String _nombreUsuario = '';
  bool _isLoading = true;
  Map<String, dynamic>? facturaSeleccionada;


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

    Future<void> _descargarFacturaTXT() async {
    if (facturaSeleccionada == null) return;

    final factura = facturaSeleccionada!;
    final detalles = factura['detalles'] as List<dynamic>? ?? [];
    final fechaFormateada = factura['fecha'] is Timestamp
        ? DateFormat('dd/MM/yyyy').format((factura['fecha'] as Timestamp).toDate())
        : factura['fecha'] is String
            ? factura['fecha']
            : 'Sin fecha';

    final contenido = StringBuffer();
    contenido.writeln('FERREPLUS ONE');
    contenido.writeln('Factura #${factura['numero'] ?? 'N/A'}');
    contenido.writeln('Fecha: $fechaFormateada');
    contenido.writeln('\nProductos:\n');

    for (final item in detalles) {
      final nombre = item['nombre'];
      final cantidad = item['cantidad'];
      final precio = item['precio'];
      final subtotal = cantidad * precio;
      contenido.writeln('- $nombre x$cantidad → L. ${subtotal.toStringAsFixed(2)}');
    }

    contenido.writeln('\nTotal: L. ${factura['total']?.toStringAsFixed(2) ?? '0.00'}');
    contenido.writeln('\nGracias por su compra.');

    final bytes = Uint8List.fromList(contenido.toString().codeUnits);
    final name = 'factura_${factura['numero'] ?? 'N/A'}.txt';

    if (!kIsWeb) {
      final directoryPath = await getDirectoryPath();
      if (directoryPath != null) {
        final filePath = '$directoryPath/$name';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        debugPrint('Factura guardada en $filePath');
      }
    } else {
      debugPrint('Descarga TXT no disponible en Web en esta versión.');
    }
  }


    Future<void> _descargarFacturaPDF() async {
    if (facturaSeleccionada == null) return;

    final factura = facturaSeleccionada!;
    final detalles = factura['detalles'] as List<dynamic>? ?? [];

    final fechaFormateada = factura['fecha'] is Timestamp
        ? DateFormat('dd/MM/yyyy').format((factura['fecha'] as Timestamp).toDate())
        : factura['fecha'] is String
            ? factura['fecha']
            : 'Sin fecha';

    final imageUrl = 'https://i.imgur.com/CK31nrT.png';
    final response = await http.get(Uri.parse(imageUrl));
    final logo = pw.MemoryImage(response.bodyBytes);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Image(logo, height: 80)),
            pw.SizedBox(height: 16),
            pw.Text('FERREPLUS ONE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Factura No. ${factura['numero'] ?? 'N/A'}'),
            pw.Text('Fecha: $fechaFormateada'),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Text('Detalles de productos:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            detalles.isEmpty
                ? pw.Text('No hay productos.')
                : pw.Table.fromTextArray(
                    headers: ['Producto', 'Cantidad', 'Precio', 'Subtotal'],
                    data: detalles.map((item) {
                      final cantidad = item['cantidad'];
                      final precio = item['precio'];
                      final subtotal = cantidad * precio;
                      return [
                        item['nombre'],
                        cantidad.toString(),
                        'L. ${precio.toStringAsFixed(2)}',
                        'L. ${subtotal.toStringAsFixed(2)}',
                      ];
                    }).toList(),
                  ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: L. ${factura['total']?.toStringAsFixed(2) ?? '0.00'}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text('Gracias por su compra', style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  
    Widget _buildFacturaDetalle(Map<String, dynamic> factura) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Descargar PDF',
            onPressed: _descargarFacturaPDF,
          ),
          IconButton(
            icon: const Icon(Icons.text_snippet),
            tooltip: 'Descargar TXT',
            onPressed: _descargarFacturaTXT,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('Factura No. ${factura['numero'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                  Text(
                    'Fecha: ${factura['fecha'] is Timestamp ? DateFormat('dd/MM/yyyy').format((factura['fecha'] as Timestamp).toDate()) : factura['fecha'] ?? 'Sin fecha'}',
                  ),
                  const SizedBox(height: 16),
                  const Text('Productos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...((factura['detalles'] ?? []) as List<dynamic>).map((item) {
                    final nombre = item['nombre'];
                    final cantidad = item['cantidad'];
                    final precio = item['precio'];
                    final subtotal = cantidad * precio;
                    return ListTile(
                      title: Text(nombre),
                      subtitle: Text('Cantidad: $cantidad'),
                      trailing: Text('L. ${subtotal.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: L. ${factura['total']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => facturaSeleccionada = null),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al listado'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
   Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Facturas'),
            )
          : null,
      drawer: isMobile
          ? FacturasClienteDrawer(
              auth: FirebaseAuth.instance,
              nombreUsuario: _nombreUsuario,
              isLoading: _isLoading,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            FacturasClienteContent(
              auth: FirebaseAuth.instance,
              nombreUsuario: _nombreUsuario,
              isLoading: _isLoading,
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
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
                                : factura['fecha']?.toString() ?? 'Sin fecha';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Factura #${factura['numero'] ?? 'N/A'}'),
                                subtitle: Text('Total: L. ${factura['total']?.toStringAsFixed(2) ?? '0.00'}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(fechaFormateada),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      tooltip: 'Descargar TXT',
                                      onPressed: () {
                                                  setState(() {
                                                    facturaSeleccionada = factura; 
                                                  });
                                                  _descargarFacturaTXT(); 
                                                },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf),
                                      tooltip: 'Descargar PDF',
                                      onPressed: () {
                                                setState(() {
                                                  facturaSeleccionada = factura; 
                                                });
                                                _descargarFacturaPDF(); 
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