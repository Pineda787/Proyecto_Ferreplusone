import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final List<Map<String, dynamic>> ventas = const [
    {'mes': 'Enero', 'total': 500},
    {'mes': 'Febrero', 'total': 750},
    {'mes': 'Marzo', 'total': 300},
    {'mes': 'Abril', 'total': 900},
    {'mes': 'Mayo', 'total': 650},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🟧 Menú lateral estilo LoginScreen
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            color: Colors.orange, // ← Color igual que LoginScreen
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.network(
                  'https://i.imgur.com/CK31nrT.png',
                  height: 280,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text('MENU', style: menuTextStyle),
                const SizedBox(height: 30),
                _buildMenuButton(context, 'INVENTARIO', '/inventario'),
                _buildMenuButton(context, 'REPORTES', '/reportes'),
                _buildMenuButton(context, 'CONFIGURACIÓN DE USUARIOS', '/configuracion'),
                _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuAdmin'),
                const Spacer(),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(_nombreUsuario, style: const TextStyle(color: Colors.white, fontSize: 16)),
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

          // 📄 Área principal con reportes
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('REPORTES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ventas.length,
                      itemBuilder: (context, index) {
                        final venta = ventas[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange, // ← Igual que en LoginScreen
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(venta['mes']),
                            subtitle: Text('Total: L${venta['total']} lempiras'),
                            trailing: const Icon(Icons.bar_chart),
                          ),
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

  // 📌 Botón de menú modular
  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: menuButtonStyle,
        onPressed: () {
          Navigator.pushReplacementNamed(context, route);
        },
        child: Text(label, style: menuButtonText),
      ),
    );
  }

  // 🎨 Estilos reutilizados (idénticos a LoginScreen)
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
    color: Colors.orange, // ← Mismo naranja de LoginScreen
    fontSize: 16,
  );
}