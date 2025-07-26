import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _email = _email.trim().toLowerCase();
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        final uid = userCredential.user!.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        final data = userDoc.data() as Map<String, dynamic>?;
        if (data == null || !data.containsKey('rol')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil incompleto o rol no definido')),
          );
          return;
        }

        String role = data['rol'];
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/menuAdmin');
        } else if (role == 'cliente') {
          Navigator.pushReplacementNamed(context, '/menuCliente');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol desconocido')),
          );
          Navigator.pushReplacementNamed(context, '/');
        }
      } on FirebaseAuthException catch (e) {
        String message = switch (e.code) {
          'user-not-found' => 'Usuario no encontrado',
          'wrong-password' => 'Contraseña incorrecta',
          'invalid-email' => 'Correo inválido',
          _ => e.message ?? 'Error de autenticación',
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🟧 Panel lateral izquierdo con logo institucional
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
                Text('MENU', style: menuTextStyle),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: menuButtonStyle,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('CREAR USUARIO', style: menuButtonText),
                ),
                const Spacer(),
                ElevatedButton(
                  style: menuButtonStyle,
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Text('SALIR', style: menuButtonText),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 🎨 Panel visual derecho con fondo animado
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeInImage.assetNetwork(
                  placeholder: 'assets/loading.png',
                  image: 'https://i.imgur.com/TtxRcj4.png',
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withOpacity(0.6)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'INICIAR SESIÓN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            validator: (value) {
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (value == null || value.isEmpty) return 'El correo es requerido';
              if (!emailRegex.hasMatch(value)) return 'Correo inválido';
              return null;
            },
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) => value == null || value.length < 6
                ? 'La contraseña debe tener al menos 6 caracteres'
                : null,
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _handleLogin,
                  child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('¿No tienes una cuenta? Regístrate'),
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