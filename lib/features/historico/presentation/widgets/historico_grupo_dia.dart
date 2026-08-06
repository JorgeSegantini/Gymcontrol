import 'package:flutter/material.dart';

import '../../data/historico_models.dart';
import 'historico_treino_card.dart';

class HistoricoGrupoDiaWidget extends StatelessWidget {
  const HistoricoGrupoDiaWidget({
    required this.grupo,
    required this.onTreinoTap,
    super.key,
  });

  final HistoricoGrupoDia grupo;
  final ValueChanged<HistoricoTreinoResumo> onTreinoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Text(
            _rotuloData(grupo.data),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        for (var indice = 0; indice < grupo.treinos.length; indice++) ...[
          HistoricoTreinoCard(
            treino: grupo.treinos[indice],
            onTap: () {
              onTreinoTap(grupo.treinos[indice]);
            },
          ),
          if (indice < grupo.treinos.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  static String _rotuloData(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));

    if (data == hoje) {
      return 'Hoje';
    }

    if (data == ontem) {
      return 'Ontem';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }
}
