import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class BibliotecaGruposMuscularesPage extends StatelessWidget {
  const BibliotecaGruposMuscularesPage({required this.database, super.key});

  final AppDatabase database;

  Stream<List<BibliotecaGrupoMuscular>> _observarGrupos() {
    final consulta = database.select(database.bibliotecaGruposMusculares)
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.nome),
      ]);

    return consulta.watch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca Oficial')),
      body: StreamBuilder<List<BibliotecaGrupoMuscular>>(
        stream: _observarGrupos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final grupos = snapshot.data!;

          if (grupos.isEmpty) {
            return const Center(
              child: Text('Nenhum grupo muscular oficial instalado.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grupos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final grupo = grupos[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${grupo.ordem}')),
                  title: Text(grupo.nome),
                  subtitle: Text(grupo.codigo),
                  trailing: grupo.ativo
                      ? const Icon(Icons.check_circle_outline)
                      : const Icon(Icons.block_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
