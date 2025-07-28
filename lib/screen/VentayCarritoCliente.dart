import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/venta_y_carrito_content.dart';
import 'widgets/venta_y_carrito_drawer.dart';

class VentasClienteScreen extends StatefulWidget {
  const VentasClienteScreen({super.key});

  @override
  State<VentasClienteScreen> createState() => _VentasClienteScreenState();
}

class _VentasClienteScreenState extends State<VentasClienteScreen> {
  final List<Map<String, dynamic>> carrito = [];
  String _nombreUsuario = '';
  bool _isLoading = true;
  bool mostrarCarrito = true; //  Esta controla el panel en escritorio


  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _cargarNombreUsuario(user.uid);
    }
  }

  void _cargarNombreUsuario(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    setState(() {
      _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario';
      _isLoading = false;
    });
  }

  void agregarAlCarrito(Map<String, dynamic> producto, int cantidad) {
    final existente = carrito.indexWhere((item) => item['id'] == producto['id']);
    if (existente != -1) {
      carrito[existente]['cantidad'] += cantidad;
    } else {
      carrito.add({
        'id': producto['id'],
        'nombre': producto['NombreProducto'],
        'precio': producto['Precio'],
        'cantidad': cantidad,
      });
    }
    setState(() {});
  }

  void mostrarDialogoCantidad(Map<String, dynamic> producto) {
    int cantidad = 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cantidad para ${producto['NombreProducto']}'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            cantidad = int.tryParse(value) ?? 1;
          },
          decoration: const InputDecoration(hintText: 'Ingrese cantidad'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              agregarAlCarrito(producto, cantidad);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> realizarCompra() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final productosRef = firestore.collection('Productos');
    final uid = FirebaseAuth.instance.currentUser?.uid;

    double total = 0;
    for (var item in carrito) {
      total += item['precio'] * item['cantidad'];
      final docRef = productosRef.doc(item['id']);
      final snapshot = await docRef.get();
      final stockActual = snapshot.data()?['Stock'] ?? 0;

      if (stockActual < item['cantidad']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock insuficiente para ${item['nombre']}')),
        );
        return;
      }

      batch.update(docRef, {'Stock': stockActual - item['cantidad']});
    }

    final facturaRef = firestore.collection('facturas').doc();
    batch.set(facturaRef, {
      'clienteId': uid,
      'clienteNombre': _nombreUsuario,
      'usuarioQueFacturó': uid,
      'total': total,
      'numero': 'F${DateTime.now().millisecondsSinceEpoch}',
      'fecha': DateTime.now(),
      'esPrueba': false,
      'detalles': carrito,
    });

    await batch.commit();
    carrito.clear();
    setState(() {});
    Navigator.pushReplacementNamed(context, '/factura');
  }

  // Función para definir columnas de productos según tamaño de pantalla
int obtenerColumnasResponsive(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 600) return 2;
  if (width < 900) return 3;
  return 4;
}


  Widget _buildPanelProductos() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMPRAR PRODUCTOS',
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: obtenerColumnasResponsive(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final data = productos[index].data() as Map<String, dynamic>;
                      data['id'] = productos[index].id;

                      return Card(
                        elevation: 4,
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
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['NombreProducto'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['Descripcion'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('L. ${data['Precio']}'),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => mostrarDialogoCantidad(data),
                                    child: const Text('Agregar'),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildPanelCarrito() {
  return Expanded(
    flex: 1,
    child: Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carrito',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final item = carrito[index];
                return ListTile(
                  title: Text(item['nombre']),
                  subtitle: Text('Cantidad: ${item['cantidad']}'),
                  trailing: Text('L. ${item['precio'] * item['cantidad']}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: carrito.isNotEmpty ? realizarCompra : null,
            child: const Text('Realizar compra'),
          ),
        ],
      ),
    ),
  );
  }

  void _mostrarCarritoBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final item = carrito[index];
                      return ListTile(
                        title: Text(item['nombre']),
                        subtitle: Text('Cantidad: ${item['cantidad']}'),
                        trailing: Text('L. ${item['precio'] * item['cantidad']}'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: carrito.isNotEmpty ? () {
                    Navigator.pop(context);
                    realizarCompra();
                  } : null,
                  child: const Text('Finalizar compra'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


    @override
    Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta y Carrito'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  if (isMobile) {
                    _mostrarCarritoBottomSheet(context);
                  } else {
                    setState(() {
                      mostrarCarrito = !mostrarCarrito;
                    });
                  }
                },
              ),
              if (carrito.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      carrito.fold<int>(0, (sum, item) => sum + (item['cantidad'] as int)).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: isMobile
    ? Drawer(
        backgroundColor: Colors.orange,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: VentaYCarritoContent(
              auth: FirebaseAuth.instance,
              nombreUsuario: _nombreUsuario,
              isLoading: _isLoading,
            ),
          ),
        ),
      )
    : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              color: Colors.orange,
              child: VentaYCarritoContent(
                auth: FirebaseAuth.instance,
                nombreUsuario: _nombreUsuario,
                isLoading: _isLoading,
              ),
            ),
          _buildPanelProductos(),
          if (!isMobile && mostrarCarrito) _buildPanelCarrito(),
        ],
      ),
    );
  }
}



