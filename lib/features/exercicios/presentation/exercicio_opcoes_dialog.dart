import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/codigo_formatador.dart';

enum AcaoExercicio { editar, alterarSituacao }

class ExercicioOpcoesDialog extends StatelessWidget {
  const ExercicioOpcoesDialog({required this.exercicio, super.key});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercicio.nome),
          const SizedBox(height: 4),
          Text(
            CodigoFormatador.exercicio(exercicio.id),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, AcaoExercicio.editar);
          },
          child: const Row(
            children: [Icon(Icons.edit), SizedBox(width: 12), Text('Editar')],
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, AcaoExercicio.alterarSituacao);
          },
          child: Row(
            children: [
              Icon(exercicio.ativo ? Icons.visibility_off : Icons.visibility),
              const SizedBox(width: 12),
              Text(exercicio.ativo ? 'Inativar' : 'Ativar'),
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
