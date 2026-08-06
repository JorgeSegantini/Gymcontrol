import 'package:flutter/material.dart';

import '../../data/evolucao_models.dart';

class EvolucaoExercicioCard extends StatelessWidget {
  const EvolucaoExercicioCard({
    required this.exercicio,
    required this.onTap,
    super.key,
  });

  final EvolucaoExercicioResumo exercicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
                child: const Icon(Icons.trending_up_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercicio.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Última execução',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatarSerie(exercicio),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatarData(exercicio.ultimaData),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercicio.quantidadeExecucoes == 1
                          ? 'Executado 1 vez'
                          : 'Executado ${exercicio.quantidadeExecucoes} vezes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatarSerie(EvolucaoExercicioResumo exercicio) {
    final carga = _formatarCarga(exercicio.ultimaCargaGramas);
    final repeticoes = exercicio.ultimasRepeticoes?.toString() ?? '—';
    final rir = exercicio.ultimoRir?.toString() ?? '—';

    return '$carga × $repeticoes • RIR $rir';
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

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }
}
