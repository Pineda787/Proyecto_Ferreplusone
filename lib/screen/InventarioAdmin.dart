import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class InventarioAdminScreen extends StatefulWidget {
  const InventarioAdminScreen({super.key});

  @override
  State<InventarioAdminScreen> createState() => _InventarioAdminScreenState();
}

class _InventarioAdminScreenState extends State<InventarioAdminScreen> {
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
        if (rol != 'admin') {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _nombreUsuario = data?['nombre'] ?? 'Admin';
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
          // 🟧 Menú lateral estilo admin
          Container(
            width: screenWidth * 0.25,
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
                _buildMenuButton(context, 'INVENTARIO', '/inventarioAdmin'),
                _buildMenuButton(context, 'REPORTES', '/reportes'),
                _buildMenuButton(
                  context,
                  'CONFIGURACIÓN DE USUARIOS',
                  '/configuracion',
                ),
                _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuAdmin'),

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

          // 🛠️ Panel principal - Gestión de inventario
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
                  // 📋 Header con título y acciones
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
                          'GESTIÓN DE INVENTARIO',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        // Botón para agregar producto
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () => _mostrarDialogoNuevoProducto(),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'NUEVO PRODUCTO',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _mostrarDialogoNuevoProducto(),
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      'Agregar primer producto',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
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

                              return _buildProductCard(
                                producto.id,
                                data,
                                stock,
                              );
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

  //  Widget para crear botón de menú
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

  //  Widget para tarjeta de producto con controles admin
  Widget _buildProductCard(
    String productId,
    Map<String, dynamic> data,
    int stock,
  ) {
    final stockBajo = stock < 10;

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
            //  Imagen del producto
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
                              '¡STOCK BAJO!',
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

            //  Información del producto
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
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Stock con colores
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockBajo ? Colors.red[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stock: $stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: stockBajo
                              ? Colors.red[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //  Controles de admin
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Restar stock
                  _buildStockButton(
                    Icons.remove,
                    Colors.orange,
                    () => _ajustarStock(productId, stock - 1),
                    stock > 0,
                  ),

                  // Agregar stock
                  _buildStockButton(
                    Icons.add,
                    Colors.orange,
                    () => _ajustarStock(productId, stock + 1),
                    true,
                  ),

                  // Editar producto
                  _buildStockButton(
                    Icons.edit,
                    Colors.orange,
                    () => _mostrarDialogoEditarProducto(productId, data),
                    true,
                  ),

                  // Eliminar producto
                  _buildStockButton(
                    Icons.delete,
                    Colors.orange,
                    () => _confirmarEliminarProducto(
                      productId,
                      data['NombreProducto'],
                    ),
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Widget para botones de control de stock
  Widget _buildStockButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool enabled,
  ) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? color : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 16, color: enabled ? color : Colors.grey[600]),
      ),
    );
  }

  //  Mostrar diálogo para nuevo producto
  void _mostrarDialogoNuevoProducto() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();
    final imagenController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.add_box, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Nuevo Producto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  nombreController,
                  'Nombre del producto',
                  Icons.hardware,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  descripcionController,
                  'Descripción',
                  Icons.description,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  precioController,
                  'Precio',
                  Icons.attach_money,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  stockController,
                  'Stock inicial',
                  Icons.inventory,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  imagenController,
                  'URL de imagen',
                  Icons.image,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (nombreController.text.isNotEmpty &&
                    precioController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  await _crearNuevoProducto(
                    nombreController.text,
                    descripcionController.text,
                    double.tryParse(precioController.text) ?? 0.0,
                    int.tryParse(stockController.text) ?? 0,
                    imagenController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Crear Producto'),
            ),
          ],
        );
      },
    );
  }

  //  Mostrar diálogo para editar producto
  void _mostrarDialogoEditarProducto(
    String productId,
    Map<String, dynamic> data,
  ) {
    final nombreController = TextEditingController(
      text: data['NombreProducto'],
    );
    final descripcionController = TextEditingController(
      text: data['Descripcion'] ?? '',
    );
    final precioController = TextEditingController(
      text: data['Precio'].toString(),
    );
    final stockController = TextEditingController(
      text: data['Stock'].toString(),
    );
    final imagenController = TextEditingController(text: data['ImagenURL']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Editar Producto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  nombreController,
                  'Nombre del producto',
                  Icons.hardware,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  descripcionController,
                  'Descripción',
                  Icons.description,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  precioController,
                  'Precio',
                  Icons.attach_money,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  stockController,
                  'Stock',
                  Icons.inventory,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  imagenController,
                  'URL de imagen',
                  Icons.image,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await _actualizarProducto(
                  productId,
                  nombreController.text,
                  descripcionController.text,
                  double.tryParse(precioController.text) ?? 0.0,
                  int.tryParse(stockController.text) ?? 0,
                  imagenController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  //  Widget para campos de texto del diálogo
  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  //  Ajustar stock de producto
  Future<void> _ajustarStock(String productId, int nuevoStock) async {
    if (nuevoStock < 0) return;

    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(productId)
          .update({'Stock': nuevoStock});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock actualizado a $nuevoStock'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar stock: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //  Crear nuevo producto
  Future<void> _crearNuevoProducto(
    String nombre,
    String descripcion,
    double precio,
    int stock,
    String imagenUrl,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('Productos').add({
        'NombreProducto': nombre,
        'Descripcion': descripcion,
        'Precio': precio,
        'Stock': stock,
        'ImagenURL': imagenUrl.isNotEmpty
            ? imagenUrl
            : 'https://via.placeholder.com/150?text=Sin+Imagen',
        'FechaCreacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto creado exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //  Actualizar producto existente
  Future<void> _actualizarProducto(
    String productId,
    String nombre,
    String descripcion,
    double precio,
    int stock,
    String imagenUrl,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(productId)
          .update({
            'NombreProducto': nombre,
            'Descripcion': descripcion,
            'Precio': precio,
            'Stock': stock,
            'ImagenURL': imagenUrl.isNotEmpty
                ? imagenUrl
                : 'https://via.placeholder.com/150?text=Sin+Imagen',
            'FechaActualizacion': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //  Confirmar eliminación de producto
  void _confirmarEliminarProducto(String productId, String nombreProducto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Confirmar Eliminación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar el producto "$nombreProducto"?\n\nEsta acción no se puede deshacer.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await _eliminarProducto(productId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  //  Eliminar producto
  Future<void> _eliminarProducto(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
