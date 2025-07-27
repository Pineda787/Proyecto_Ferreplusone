import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screen/admin_inventario_screen.dart';
import 'screen/cliente_inventario_screen.dart';
import 'screen/loginScreen.dart';
import 'screen/registerScreen.dart';
import 'screen/menuAdmin.dart';
import 'screen/menuCliente.dart';
import 'screen/ConfiguracionUsuarios.dart';
import 'screen/reportes.dart';

import 'screen/VentayCarritoCliente.dart';
import 'screen/FacturaCliente.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Ferretería',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/menuAdmin': (context) => MenuAdmin(),
        '/menuCliente': (context) => MenuCliente(),
        '/admin': (context) => AdminInventarioScreen(),
        '/cliente': (context) => ClienteInventarioScreen(),
        '/inventarioAdmin': (context) => AdminInventarioScreen(),
        '/inventario': (context) => ClienteInventarioScreen(),
        '/configuracion': (context) => ConfiguracionUsuariosScreen(),
        '/reportes': (context) => ReportesScreen(),
        '/ventas': (context) => VentasClienteScreen(),
        '/factura': (context) => FacturaClienteScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCDCDC),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDCDCDC),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono principal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF0F2F54),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'FERREPLUS',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2F54),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'SISTEMA DE INVENTARIO',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 40),
              // Botones de autenticación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F2F54),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'INICIAR SESIÓN',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6600),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'REGISTRARSE',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                'O accede directamente como:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                // En pantallas pequeñas, mostrar las tarjetas en columna
                if (constraints.maxWidth < 480) {
                  return Column(
                    children: [
                      _buildRoleCard(
                        context,
                        'Administrador',
                        Icons.admin_panel_settings,
                        '/admin',
                      ),
                      SizedBox(height: 20),
                      _buildRoleCard(
                        context,
                        'Cliente',
                        Icons.person,
                        '/cliente',
                      ),
                    ],
                  );
                } else {
                  // En pantallas más grandes, mostrar en fila
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleCard(
                        context,
                        'Administrador',
                        Icons.admin_panel_settings,
                        '/admin',
                      ),
                      SizedBox(width: 30),
                      _buildRoleCard(
                        context,
                        'Cliente',
                        Icons.person,
                        '/cliente',
                      ),
                    ],
                  );
                }
              },
            ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon, String route) {
    bool isAdmin = title == 'Administrador';
    Color primaryColor = isAdmin ? Color(0xFF0F2F54) : Color(0xFFFF6600);
    Color secondaryColor = isAdmin ? Color(0xFFFF6600) : Color(0xFF0F2F54);
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width > 480 ? 220 : 200,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamed(context, route),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}