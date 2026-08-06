import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

enum AcaoFichaTreino { editar, alterarSituacao }

class FichaTreinoOpcoesDialog extends StatelessWidget {
  const FichaTreinoOpcoesDialog({required this.fichaTreino, super.key});

  final FichaTreino fichaTreino;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mais opções'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar ficha'),
            subtitle: const Text('Alterar nome, descrição e ordem'),
            onTap: () {
              Navigator.of(context).pop(AcaoFichaTreino.editar);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              fichaTreino.ativo
                  ? Icons.archive_outlined
                  : Icons.unarchive_outlined,
            ),
            title: Text(fichaTreino.ativo ? 'Inativar ficha' : 'Ativar ficha'),
            subtitle: Text(
              fichaTreino.ativo
                  ? 'A ficha deixará de aparecer entre as ativas'
                  : 'A ficha voltará a aparecer entre as ativas',
            ),
            onTap: () {
              Navigator.of(context).pop(AcaoFichaTreino.alterarSituacao);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
