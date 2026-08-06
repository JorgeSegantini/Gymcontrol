import 'package:flutter/material.dart';

import '../../data/historico_models.dart';

class HistoricoExercicioCard extends StatelessWidget {
  const HistoricoExercicioCard({required this.exercicio, super.key});

  final HistoricoExercicioDetalhe exercicio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Text(
            '${exercicio.ordem}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          exercicio.nome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${exercicio.quantidadeSeriesConcluidas} séries concluídas'
          ' • ${_formatarVolume(exercicio.volumeTotalGramas)}',
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (var indice = 0; indice < exercicio.series.length; indice++) ...[
            _HistoricoSerieLinha(serie: exercicio.series[indice]),
            if (indice < exercicio.series.length - 1) const Divider(height: 14),
          ],
        ],
      ),
    );
  }

  static String _formatarVolume(int volumeGramas) {
    final quilos = volumeGramas / 1000;

    if (quilos == quilos.roundToDouble()) {
      return '${quilos.toInt()} kg';
    }

    return '${quilos.toStringAsFixed(1)} kg';
  }
}

class _HistoricoSerieLinha extends StatelessWidget {
  const _HistoricoSerieLinha({required this.serie});

  final HistoricoSerieDetalhe serie;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final concluida = serie.concluida;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: concluida
                ? colorScheme.tertiaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${serie.ordem}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: concluida
                  ? colorScheme.onTertiaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            concluida
                ? '${_formatarCarga(serie.cargaGramas)} × '
                      '${serie.repeticoes ?? '—'}'
                : 'Série não realizada',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (concluida)
          Text(
            'RIR ${serie.rir ?? '—'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          Text(
            'Pulada',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  static String _formatarCarga(int? cargaGramas) {
    if (cargaGramas == null) {
      return '—';
    }

    final quilos = cargaGramas / 1000;

    if (quilos == quilos.roundToDouble()) {
      return '${quilos.toInt()} kg';
    }

    return '${quilos.toStringAsFixed(1)} kg';
  }
}
