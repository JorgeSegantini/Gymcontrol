import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

enum AcaoGrupoMuscular { editar, alterarSituacao }

class GrupoMuscularOpcoesDialog extends StatelessWidget {
  const GrupoMuscularOpcoesDialog({required this.grupo, super.key});

  final GrupoMuscular grupo;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(grupo.nome),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, AcaoGrupoMuscular.editar);
          },
          child: const Row(
            children: [Icon(Icons.edit), SizedBox(width: 12), Text('Editar')],
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, AcaoGrupoMuscular.alterarSituacao);
          },
          child: Row(
            children: [
              Icon(grupo.ativo ? Icons.visibility_off : Icons.visibility),
              const SizedBox(width: 12),
              Text(grupo.ativo ? 'Inativar' : 'Ativar'),
            ],
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Row(
            children: [
              Icon(Icons.close),
              SizedBox(width: 12),
              Text('Cancelar'),
            ],
          ),
        ),
      ],
    );
  }
}
