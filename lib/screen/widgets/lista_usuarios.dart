import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaUsuarios extends StatelessWidget {
  final void Function(String docId) onEliminarUsuario;
  final void Function(String docId, Map<String, dynamic> usuario)? onEditarUsuario;

  const ListaUsuarios({
    required this.onEliminarUsuario,
    this.onEditarUsuario,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.white);
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Text(
              'No hay usuarios registrados.',
              style: TextStyle(color: Colors.white),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Card(
                color: Colors.white.withOpacity(0.9),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: Text(data['nombre'] ?? 'Sin nombre'),
                  subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['correo'] ?? 'Sin correo'),
                                    Text('Rol: ${data['rol'] ?? 'No definido'}'),
                                  ],
                                ),
                                isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          if (onEditarUsuario != null) {
                            onEditarUsuario!(docId, data);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onEliminarUsuario(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}