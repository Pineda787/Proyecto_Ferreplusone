import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaUsuarios extends StatelessWidget {
  const ListaUsuarios({super.key});

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
            return const Text('No hay usuarios registrados.', style: TextStyle(color: Colors.white));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: Colors.white.withOpacity(0.9),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: Text(data['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(data['email'] ?? 'Sin email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
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