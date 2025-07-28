import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventarioClienteScreen extends StatefulWidget {
  const InventarioClienteScreen({super.key});

  @override
  State<InventarioClienteScreen> createState() =>
      _InventarioClienteScreenState();
}

class _InventarioClienteScreenState extends State<InventarioClienteScreen> {
  String _nombreUsuario = '';
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          // 🟧 Menú lateral estilo cliente
          Container(
            width: screenWidth * 0.25,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 🛠️ Panel principal - Vista de inventario
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
                ),
              ),
              child: Column(
                children: [
                  // 📋 Header con título
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'INVENTARIO DISPONIBLE',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        // Indicador de vista solo lectura
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'SOLO LECTURA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔍 Barra de búsqueda
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar productos por nombre...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),

                  // 📦 Grid de productos
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Productos')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                  SizedBox(height: 16),
                                  Text('Cargando inventario...'),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No hay productos en el inventario',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          var productos = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final nombre =
                                data['NombreProducto']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';
                            return nombre.contains(_searchQuery);
                          }).toList();

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              final producto = productos[index];
                              final data =
                                  producto.data() as Map<String, dynamic>;
                              final stock = data['Stock'] ?? 0;

                              return _buildProductCard(data, stock);
                            },
                          );
                        },
                      ),
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

  // 🔧 Widget para crear botón de menú
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
          style: const TextStyle(color: Colors.orange, fontSize: 16),
        ),
      ),
    );
  }

  // 🛠️ Widget para tarjeta de producto (solo vista)
  Widget _buildProductCard(Map<String, dynamic> data, int stock) {
    final stockBajo = stock < 10;
    final disponible = stock > 0;

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: stockBajo
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          children: [
            // 🏷️ Imagen del producto
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        data['ImagenURL'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.hardware,
                            size: 60,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      // Indicador de stock bajo
                      if (stockBajo)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '¡POCAS UNIDADES!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (!disponible)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'SIN STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 📋 Información del producto
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Nombre del producto
                    Text(
                      data['NombreProducto'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Precio
                    Text(
                      '\$${(data['Precio'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Stock con colores
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: !disponible
                            ? Colors.grey[300]
                            : stockBajo
                            ? Colors.red[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stock: $stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !disponible
                              ? Colors.grey[700]
                              : stockBajo
                              ? Colors.red[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🎯 Estado de disponibilidad
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: disponible ? Colors.orange[50] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    disponible ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: disponible ? Colors.orange : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    disponible ? 'DISPONIBLE' : 'NO DISPONIBLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: disponible ? Colors.orange : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
