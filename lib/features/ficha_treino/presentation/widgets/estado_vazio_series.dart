import 'package:flutter/material.dart';

import '../../../../shared/theme/widgets/gc_empty_state.dart';

class EstadoVazioSeries extends StatelessWidget {
  const EstadoVazioSeries({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 64),
      child: GcEmptyState(
        icone: Icons.format_list_numbered,
        titulo: 'Nenhuma série planejada',
        descricao:
            'Use o botão “Adicionar série” para começar a configurar este exercício.',
      ),
    );
  }
}
