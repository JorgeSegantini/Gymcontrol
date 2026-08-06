import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';

class CabecalhoExercicio extends StatelessWidget {
  const CabecalhoExercicio({
    required this.rirPlanejado,
    required this.observacoes,
    required this.ativo,
    super.key,
  });

  final int? rirPlanejado;
  final String? observacoes;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final observacoesTratadas = observacoes?.trim();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.fitness_center)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.battery_5_bar, size: 18),
                      label: Text(
                        rirPlanejado == null
                            ? 'RIR não definido'
                            : 'RIR $rirPlanejado',
                      ),
                    ),
                    if (!ativo)
                      const Chip(
                        avatar: Icon(Icons.block, size: 18),
                        label: Text('Inativo'),
                      ),
                  ],
                ),
                if (observacoesTratadas != null &&
                    observacoesTratadas.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    observacoesTratadas,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
