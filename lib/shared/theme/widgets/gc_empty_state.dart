import 'package:flutter/material.dart';

import '../app_spacing.dart';

class GcEmptyState extends StatelessWidget {
  const GcEmptyState({
    required this.icone,
    required this.titulo,
    required this.descricao,
    super.key,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              titulo,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              descricao,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (acao != null) ...[const SizedBox(height: AppSpacing.lg), acao!],
          ],
        ),
      ),
    );
  }
}
