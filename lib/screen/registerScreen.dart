import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  String _address = '';
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim(),
      );

      final uid = userCredential.user!.uid;

      await _firestore.collection('usuarios').doc(uid).set({
        'nombre': _name.trim(),
        'correo': _email.trim(),
        'direccion': _address.trim(),
        'rol': 'cliente',
      });

      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Registro exitoso! Por favor, inicia sesión.')),
        );
      } else {
        throw Exception('No se pudo verificar el documento en Firestore');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error desconocido')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar datos.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'REGISTRO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nombre Completo'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'El nombre es requerido' : null,
            onSaved: (value) => _name = value ?? '',
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value == null || !value.contains('@') ? 'Correo no válido' : null,
            onSaved: (value) => _email = value ?? '',
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            validator: (value) =>
                value == null || value.length < 6 ? 'Debe tener al menos 6 caracteres' : null,
            onSaved: (value) => _password = value ?? '',
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Dirección'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'La dirección es requerida' : null,
            onSaved: (value) => _address = value ?? '',
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _handleRegister,
                  child: const Text('Registrarse', style: TextStyle(fontSize: 18)),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🟧 Panel izquierdo con menú
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            color: Colors.orange,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.network(
                  'https://i.imgur.com/CK31nrT.png',
                  height: 280,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 40),
                Center(child: Text('MENU', style: menuTextStyle)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: menuButtonStyle,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('INICIAR SESIÓN', style: menuButtonText),
                ),
                const Spacer(),
                ElevatedButton(
                  style: menuButtonStyle,
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('SALIR', style: menuButtonText),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // 🎨 Panel derecho con imagen oscura y formulario
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://i.imgur.com/TtxRcj4.png',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
                Container(color: Colors.black.withOpacity(0.6)), // misma opacidad que login
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: buildForm(),
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

  // 🎨 Estilos compartidos
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
    color: Colors.orange,
    fontSize: 16,
  );
}