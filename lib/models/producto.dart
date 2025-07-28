import 'package:flutter/material.dart';

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
      descripcion: 'Martillo de carpintero',
      stock: 0,
      iconPath: 'assets/icons/IMG-MARTILO I ADMIN.png',
    ),
    Producto(
      id: '2',
      nombre: 'Pala',
      descripcion: 'Pala de jardín',
      stock: 64,
      iconPath: 'assets/icons/IMG-DESTORNILLADOR I ADMIN.png',
    ),
    Producto(
      id: '3',
      nombre: 'Manguera',
      descripcion: 'Manguera de jardín',
      stock: 27,
      iconPath: 'assets/icons/IMG-TALADRO I ADMIN.png',
    ),
  ];

  List<Producto> get productos => List.unmodifiable(_productos);

  List<Producto> getAll() {
    return List.unmodifiable(_productos);
  }

  List<Producto> searchByName(String query) {
    if (query.isEmpty) return getAll();
    return _productos
        .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void updateStock(String productId, int newStock) {
    final index = _productos.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _productos[index].stock = newStock;
      notifyListeners();
    }
  }

  void addProduct(Producto producto) {
    _productos.add(producto);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _productos.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  Producto? getProduct(String productId) {
    try {
      return _productos.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }
}
