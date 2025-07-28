import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/menu_content.dart';
import 'widgets/menu_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  void _checkFirebaseConnection() {
    try {
      print(" Firebase Auth inicializado: ${_auth.app.name}");
      print(" Usuario actual: ${_auth.currentUser}");
    } catch (e) {
      print(" Error al verificar Firebase Auth: $e");
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      _email = _email.trim().toLowerCase();
      setState(() => _isLoading = true);

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        if (userCredential.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no válido')),
          );
          return;
        }

        final uid = userCredential.user!.uid;
        final userDoc = await FirebaseFirestore.instance
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

        final role = data['rol'];
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
        final message = switch (e.code) {
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showResetPasswordDialog() {
    String _resetEmail = '';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Restablecer Contraseña'),
          content: TextFormField(
            decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _resetEmail = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _auth.sendPasswordResetEmail(email: _resetEmail.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo de recuperación enviado')),
                  );
                } on FirebaseAuthException catch (e) {
                  final message = switch (e.code) {
                    'user-not-found' => 'Correo no registrado',
                    'invalid-email' => 'Correo inválido',
                    _ => 'Error: ${e.message}',
                  };
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text('Ferretería OnePlus')) : null,
      drawer: isMobile ? MenuDrawer(auth: _auth) : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              color: Colors.orange,
              child: MenuContent(auth: _auth),
            ),
          Expanded(child: buildMainPanel()),
        ],
      ),
    );
  }

  Widget buildMainPanel() {
    return Stack(
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
            padding: const EdgeInsets.all(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: buildForm(),
            ),
          ),
        ),
      ],
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
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
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('¿No tienes una cuenta? Regístrate'),
          ),
          TextButton(
            onPressed: _showResetPasswordDialog,
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
        ],
      ),
    );
  }



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
