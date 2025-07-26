import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_inventario_screen.dart'; // Para acceder al InventoryController y Producto

// Pantalla Cliente Inventario
class ClienteInventarioScreen extends StatefulWidget {
  @override
  _ClienteInventarioScreenState createState() => _ClienteInventarioScreenState();
}

class _ClienteInventarioScreenState extends State<ClienteInventarioScreen> {
  final InventoryController _controller = InventoryController();
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _filteredProducts = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _filteredProducts = _controller.getAll();
    _controller.addListener(() {
      _filterProducts(_searchController.text);
    });
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _controller.searchByName(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFDCDCDC),
      appBar: MediaQuery.of(context).size.width < 900
          ? AppBar(
              backgroundColor: Color(0xFFD9D9D9),
              foregroundColor: Color(0xFF0F2F54),
              title: Text(
                'INVENTARIO',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
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
            )
          : null,
      drawer: MediaQuery.of(context).size.width < 900 ? _buildDrawer() : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Row(
                children: [
                  _buildSideMenu(),
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

  Widget _buildSideMenu() {
    return Container(
      width: 200,
      color: Color(0xFFFF6600),
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
          _buildMenuItem('VENTAS', false),
          _buildMenuItem('FACTURA', false),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
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
                    'Pedro53',
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
            _buildMenuItem('VENTAS', false),
            _buildMenuItem('FACTURA', false),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22,
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
                      'Pedro53',
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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width >= 900)
            Text(
              'INVENTARIO',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F2F54),
              ),
            ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF0F2F54)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF0F2F54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty 
                  ? 'No hay productos en el inventario'
                  : 'No se encontraron resultados para "${_searchController.text}"',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildProductCard(_filteredProducts[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    String clientIconPath = _getClientIconPath(producto.iconPath);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  clientIconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.inventory, color: Colors.grey);
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          producto.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F2F54),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: producto.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: producto.stock > 0 ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          producto.stock > 0 ? 'Disponible' : 'Agotado',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: producto.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    producto.descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Stock: ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${producto.stock}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: producto.stock > 10 ? Colors.green : 
                                 producto.stock > 0 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getClientIconPath(String adminIconPath) {
    Map<String, String> iconMapping = {
      'assets/icons/IMG-MARTILO I ADMIN.png': 'assets/icons/IMG-MARTILLO I CLIENTE.png',
      'assets/icons/IMG-TALADRO I ADMIN.png': 'assets/icons/IMG-TALADRO I CLIENTE.png',
      'assets/icons/IMG-DESTORNILLADOR I ADMIN.png': 'assets/icons/IMG-DESTORNILLADOR I CLIENTE.png',
      'assets/icons/IMG-TABLAS I ADMIN.png': 'assets/icons/IMG-TABLAS I CLIENTE.png',
      'assets/icons/IMG-LATAS I ADMIN.png': 'assets/icons/IMG-LATA I CLIENTE.png',
      'assets/icons/IMG-TORNILLOS I ADMIN.png': 'assets/icons/IMG- Tornillo CLIENTE .png',
    };
    
    return iconMapping[adminIconPath] ?? adminIconPath;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}