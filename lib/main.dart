import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// 🔧 Importaciones generadas
import 'firebase_options.dart';

// 🧩 Pantallas personalizadas
import 'package:flutter_proyecto/screen/loginScreen.dart';
import 'package:flutter_proyecto/screen/registerScreen.dart';
import 'package:flutter_proyecto/screen/reportes.dart';
import 'package:flutter_proyecto/screen/menuAdmin.dart';
import 'package:flutter_proyecto/screen/menuCliente.dart';
import 'package:flutter_proyecto/screen/ConfiguracionUsuarios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Inicialización multiplataforma con configuración automática
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferretería Plus One',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const MyHomePage(title: 'USUARIO'),
        '/reportes': (context) => const ReportesScreen(),
        '/menuAdmin': (context) => MenuAdmin(),
        '/menuCliente': (context) => MenuCliente(),
        '/configuracion': (context) => ConfiguracionUsuariosScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// 👤 Pantalla principal para usuarios
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: cuerpo(context),
    );
  }
}

Widget cuerpo(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          "https://i.imgur.com/4SQ9Sw0.jpg",
        ),
        fit: BoxFit.cover,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'BIENVENIDO A FERREPLUSONE',
            style: TextStyle(color: Colors.white, fontSize: 40),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('ACCEDER AL LOGIN'),
          ),
        ],
      ),
    ),
  );
}