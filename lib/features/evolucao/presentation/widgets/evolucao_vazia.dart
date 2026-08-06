import 'package:flutter/material.dart';

class EvolucaoVazia extends StatelessWidget {
  const EvolucaoVazia({required this.possuiBusca, super.key});

  final bool possuiBusca;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              possuiBusca
                  ? Icons.search_off_outlined
                  : Icons.trending_up_outlined,
              size: 58,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              possuiBusca
                  ? 'Nenhum exercício encontrado'
                  : 'Ainda não há evolução registrada',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              possuiBusca
                  ? 'Tente pesquisar usando outro nome.'
                  : 'Conclua treinos para acompanhar seu progresso por exercício.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
