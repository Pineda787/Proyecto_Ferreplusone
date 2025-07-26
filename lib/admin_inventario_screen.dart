import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modelo Producto
class Producto {
  String id;
  String nombre;
  String descripcion;
  int stock;
  String iconPath;
  
  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.stock,
    required this.iconPath,
  });
}

// Controlador de Inventario (Singleton)
class InventoryController extends ChangeNotifier {
  static final InventoryController _instance = InventoryController._internal();
  factory InventoryController() => _instance;
  InventoryController._internal();

  final List<Producto> _productos = [
    Producto(
      id: '1',
      nombre: 'Martillo', 
      descripcion: 'Martillo de acero resistente',
      stock: 15,
      iconPath: 'assets/icons/IMG-MARTILO I ADMIN.png',
    ),
    Producto(
      id: '2',
      nombre: 'Taladro',
      descripcion: 'Taladro eléctrico profesional', 
      stock: 8,
      iconPath: 'assets/icons/IMG-TALADRO I ADMIN.png',
    ),
    Producto(
      id: '3',
      nombre: 'Destornillador',
      descripcion: 'Set de destornilladores',
      stock: 25,
      iconPath: 'assets/icons/IMG-DESTORNILLADOR I ADMIN.png',
    ),
    Producto(
      id: '4',
      nombre: 'Tablas',
      descripcion: 'Tablas de madera tratada',
      stock: 12,
      iconPath: 'assets/icons/IMG-TABLAS I ADMIN.png',
    ),
    Producto(
      id: '5',
      nombre: 'Latas de Pintura',
      descripcion: 'Pintura para exteriores',
      stock: 20,
      iconPath: 'assets/icons/IMG-LATAS I ADMIN.png',
    ),
    Producto(
      id: '6',
      nombre: 'Tornillos',
      descripcion: 'Tornillos de diferentes tamaños',
      stock: 100,
      iconPath: 'assets/icons/IMG-TORNILLOS I ADMIN.png',
    ),
  ];

  List<Producto> get productos => _productos;

  void addProduct(Producto producto) {
    _productos.add(producto);
    notifyListeners();
  }

  void updateProduct(Producto updatedProduct) {
    int index = _productos.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _productos[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _productos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  List<Producto> getAll() {
    return _productos;
  }

  List<Producto> searchByName(String query) {
    if (query.isEmpty) return _productos;
    return _productos.where((p) => 
      p.nombre.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Pantalla Admin Inventario
class AdminInventarioScreen extends StatefulWidget {
  @override
  _AdminInventarioScreenState createState() => _AdminInventarioScreenState();
}

class _AdminInventarioScreenState extends State<AdminInventarioScreen> {
  final InventoryController _controller = InventoryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFDCDCDC), // Fondo gris claro según requisito
      appBar: MediaQuery.of(context).size.width < 900
          ? AppBar(
              backgroundColor: Color(0xFFD9D9D9), // Gris según requisito
              foregroundColor: Color(0xFF0F2F54), // Azul según requisito
              title: Text(
                'INVENTARIO',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800, // ExtraBold
                  color: Color(0xFF0F2F54),
                ),
              ),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Color(0xFF0F2F54)),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _showProductForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF0F2F54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Agregar producto',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2F54),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      drawer: MediaQuery.of(context).size.width < 900 ? _buildDrawer() : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              // Versión de escritorio con menú lateral fijo
              return Row(
                children: [
                  // Menú lateral
                  _buildSideMenu(),
                  // Contenido principal
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildProductList(),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Versión móvil con menú en drawer
              return Column(
                children: [
                  _buildHeader(),
                  _buildProductList(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Menú lateral para pantallas grandes
  Widget _buildSideMenu() {
    return Container(
      width: 200, // Ancho fijo para el menú lateral según requisito
      color: Color(0xFFFF6600), // Naranja según requisito
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 32, bottom: 16),
            child: Text(
              'MENU',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMenuItem('INVENTARIO', true),
          _buildMenuItem('REPORTES', false),
          _buildMenuItem('CONFIGURACIÓN\nDE USUARIOS', false),
          _buildMenuItem('FACTURA', false),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22, // 44px de diámetro según requisito
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFFFF6600)),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pedro504',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF0F2F54),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'CERRAR SESION',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Drawer para pantallas pequeñas
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Color(0xFFFF6600),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              padding: EdgeInsets.only(left: 16, top: 32),
              color: Color(0xFFFF6600),
              child: Text(
                'MENU',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem('INVENTARIO', true),
            _buildMenuItem('REPORTES', false),
            _buildMenuItem('CONFIGURACIÓN\nDE USUARIOS', false),
            _buildMenuItem('FACTURA', false),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22, // 44px de diámetro según requisito
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFFFF6600)),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pedro504',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF0F2F54),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'CERRAR SESION',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildMenuItem(String title, bool isActive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: isActive ? Color(0xFFCC5200) : Colors.transparent, // Naranja oscuro para item activo
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold, // Todos los ítems en bold según requisito
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80, // Altura fija según requisito
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Color(0xFFD9D9D9), // Gris según requisito
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/IMG-MARTILO I ADMIN.png',
                width: 56, // Tamaño según requisito
                height: 56,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.build,
                    size: 56,
                    color: Color(0xFF0F2F54),
                  );
                },
              ),
              SizedBox(width: 16),
              Text(
                'INVENTARIO',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800, // ExtraBold
                  color: Color(0xFF0F2F54),
                ),
              ),
            ],
          ),
          // Solo mostrar el botón en pantallas grandes
          if (MediaQuery.of(context).size.width >= 900)
            ElevatedButton(
              onPressed: () => _showProductForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF0F2F54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Agregar producto',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2F54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    List<Producto> productos = _controller.getAll();
    
    if (productos.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No hay productos en el inventario',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(14), // Margen horizontal según requisito
        itemCount: productos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10), // Margen vertical según requisito
            child: _buildProductCard(productos[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFCCCCCC), width: 1), // Borde según requisito
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding según requisito
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del producto con tamaño fijo
            SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                producto.iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.inventory, color: Colors.grey);
                },
              ),
            ),
            SizedBox(width: 12), // Espaciado según requisito
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2F54), // Color azul según requisito
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    producto.descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Stock con color verde según requisito
                  Text(
                    'Stock: ${producto.stock}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF168A00), // Verde según requisito
                    ),
                  ),
                ],
              ),
            ),
            // Botones de acción
            Row(
              children: [
                IconButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showProductForm(producto: producto),
                  icon: Image.asset(
                    'assets/icons/ICONO-EDITAR I TO ADMIN.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.edit, color: Colors.black, size: 24);
                    },
                  ),
                ),
                IconButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showDeleteConfirmation(producto),
                  icon: Image.asset(
                    'assets/icons/ICONO-ELIMINAR I TO ADMIN.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.delete, color: Colors.black, size: 24);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductForm({Producto? producto}) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        producto: producto,
        onSave: (Producto newProduct) {
          if (producto == null) {
            _controller.addProduct(newProduct);
          } else {
            _controller.updateProduct(newProduct);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmar eliminación',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2F54),
          ),
        ),
        content: Text(
          '¿Está seguro de que desea eliminar "${producto.nombre}"?',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteProduct(producto.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Diálogo de formulario de producto
class ProductFormDialog extends StatefulWidget {
  final Producto? producto;
  final Function(Producto) onSave;

  ProductFormDialog({required this.onSave, this.producto});

  @override
  _ProductFormDialogState createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _stockController;
  String _selectedIcon = 'assets/icons/IMG-MARTILO I ADMIN.png';

  final List<String> _iconOptions = [
    'assets/icons/IMG-MARTILO I ADMIN.png',
    'assets/icons/IMG-TALADRO I ADMIN.png',
    'assets/icons/IMG-DESTORNILLADOR I ADMIN.png',
    'assets/icons/IMG-TABLAS I ADMIN.png',
    'assets/icons/IMG-LATAS I ADMIN.png',
    'assets/icons/IMG-TORNILLOS I ADMIN.png',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.producto?.descripcion ?? '');
    _stockController = TextEditingController(text: widget.producto?.stock.toString() ?? '');
    _selectedIcon = widget.producto?.iconPath ?? _iconOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.producto == null ? 'Agregar Producto' : 'Editar Producto',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F2F54),
          fontSize: 18,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Stock *',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el stock';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Por favor ingrese un número válido mayor o igual a 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Icono',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _iconOptions.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Row(
                      children: [
                        Image.asset(
                          icon,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.inventory);
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          icon.split('/').last.split('.').first,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIcon = value!;
                  });
                },
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '* Campos obligatorios',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final producto = Producto(
                id: widget.producto?.id ?? InventoryController().generateId(),
                nombre: _nombreController.text,
                descripcion: _descripcionController.text,
                stock: int.parse(_stockController.text),
                iconPath: _selectedIcon,
              );
              widget.onSave(producto);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0F2F54), // Color azul según requisito
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Guardar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}