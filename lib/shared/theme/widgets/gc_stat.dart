import 'package:flutter/material.dart';

import '../app_spacing.dart';

class GcStat extends StatelessWidget {
  const GcStat({
    required this.icone,
    required this.valor,
    super.key,
    this.rotulo,
  });

  final IconData icone;
  final String valor;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (rotulo != null && rotulo!.trim().isNotEmpty)
              Text(
                rotulo!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
