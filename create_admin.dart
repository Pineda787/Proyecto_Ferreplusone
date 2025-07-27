import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Creando usuario administrador...');

    // Crear usuario administrador
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'admin@ferreplus.com',
      password: 'admin123',
    );

    // Agregar información del usuario a Firestore
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userCredential.user!.uid)
        .set({
      'email': 'admin@ferreplus.com',
      'rol': 'admin',
      'nombre': 'Administrador',
      'fechaCreacion': FieldValue.serverTimestamp(),
    });

    print('✅ Usuario administrador creado exitosamente!');
    print('Email: admin@ferreplus.com');
    print('Contraseña: admin123');
    print('Rol: admin');
    
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      print('⚠️  El usuario administrador ya existe.');
      print('Email: admin@ferreplus.com');
      print('Contraseña: admin123');
    } else {
      print('❌ Error al crear usuario: ${e.message}');
    }
  } catch (e) {
    print('❌ Error inesperado: $e');
  }

  print('\n🔧 Proceso completado.');
  exit(0);
}