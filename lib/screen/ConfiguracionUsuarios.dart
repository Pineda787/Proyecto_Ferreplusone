import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionUsuariosScreen extends StatefulWidget {
  const ConfiguracionUsuariosScreen({super.key});

  @override
  State<ConfiguracionUsuariosScreen> createState() =>
      _ConfiguracionUsuariosScreenState();
}

class _ConfiguracionUsuariosScreenState extends State<ConfiguracionUsuariosScreen> {
  String _nombreAdmin = '';
  bool _isLoading = true;
  final List<String> _rolesDisponibles = ['admin', 'cliente'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _cargarNombreAdmin(user.uid);
      }
    });
  }

  void _cargarNombreAdmin(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final datos = doc.data();
      setState(() {
        _nombreAdmin = datos?['nombre'] ?? 'Administrador';
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar nombre de admin: $e');
      setState(() {
        _nombreAdmin = 'Error al cargar';
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogoEditarUsuario(String docId, Map<String, dynamic> usuario) {
    final nombreController = TextEditingController(text: usuario['nombre']);
    final correoController = TextEditingController(text: usuario['correo']);
    String rolTemp = _rolesDisponibles.contains(usuario['rol']) ? usuario['rol'] : 'cliente';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: correoController, decoration: const InputDecoration(labelText: 'Correo')),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: rolTemp,
                isExpanded: true,
                items: _rolesDisponibles.map((rol) => DropdownMenuItem(value: rol, child: Text(rol))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => rolTemp = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.trim().isEmpty || correoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre y correo no pueden estar vacíos')),
                  );
                  return;
                }
                await FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
                  'nombre': nombreController.text,
                  'correo': correoController.text,
                  'rol': rolTemp,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario actualizado')),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacionUsuario(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('usuarios').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildMenuLateral(context),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CONFIGURACIÓN DE USUARIOS',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No hay usuarios registrados.'));
                        }

                        final usuarios = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: usuarios.length,
                          itemBuilder: (context, index) {
                            final usuario = usuarios[index].data() as Map<String, dynamic>;
                            final docId = usuarios[index].id;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(usuario['nombre'] ?? 'Sin nombre'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(usuario['correo'] ?? 'Sin correo'),
                                    Text('Rol: ${usuario['rol'] ?? 'No definido'}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _mostrarDialogoEditarUsuario(docId, usuario),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.orange),
                                      onPressed: () => _confirmarEliminacionUsuario(docId),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _buildMenuLateral(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      color: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network('https://i.imgur.com/CK31nrT.png', height: 280, fit: BoxFit.contain),
          const SizedBox(height: 20),
          const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
                _buildMenuButton(context, 'INVENTARIO', '/inventarioAdmin'),
                _buildMenuButton(context, 'REPORTES', '/reportes'),
                _buildMenuButton(context, 'CONFIGURACIÓN DE USUARIOS', '/configuracion'),
          _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuAdmin'),
          const Spacer(),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(_nombreAdmin, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.orange)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }


  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        child: Text(label, style: const TextStyle(color: Colors.orange)),
      ),
    );
  }
}