import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VentasClienteScreen extends StatefulWidget {
  const VentasClienteScreen({super.key});

  @override
  State<VentasClienteScreen> createState() => _VentasClienteScreenState();
}

class _VentasClienteScreenState extends State<VentasClienteScreen> {
  final List<Map<String, dynamic>> carrito = [];
  String _nombreUsuario = '';
  bool _isLoading = true;

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
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    setState(() {
      _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario';
      _isLoading = false;
    });
  }

  void agregarAlCarrito(Map<String, dynamic> producto, int cantidad) {
    final existente = carrito.indexWhere(
      (item) => item['id'] == producto['id'],
    );
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
      'esPrueba': false, // ✅ marca la factura como válida para reportes
      'detalles': carrito,
    });

    await batch.commit();
    carrito.clear();
    setState(() {});
    Navigator.pushReplacementNamed(context, '/factura');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildMenuLateral(context),
          Expanded(
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
                      stream: FirebaseFirestore.instance
                          .collection('Productos')
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
                            child: Text('No hay productos disponibles.'),
                          );
                        }

                        final productos = snapshot.data!.docs;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            final data =
                                producto.data() as Map<String, dynamic>;
                            data['id'] = producto.id;

                            return Card(
                              elevation: 4,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      data['ImagenURL'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text('L. ${data['Precio']}'),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () =>
                                              mostrarDialogoCantidad(data),
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
          ),
          Expanded(
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
                          trailing: Text(
                            'L. ${item['precio'] * item['cantidad']}',
                          ),
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
          ),
        ],
      ),
    );
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
            'MENU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuButton(context, 'INVENTARIO', '/inventarioCliente'),
          _buildMenuButton(context, 'VENTA Y CARRITO', '/ventaCarrito'),
          _buildMenuButton(context, 'FACTURAS', '/facturas'),
          _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuCliente'),
          const Spacer(),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _nombreUsuario,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
          const SizedBox(height: 10),
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

  // 📌 Botón modular
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
