import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';

class InformacaoSerie extends StatelessWidget {
  const InformacaoSerie({required this.icone, required this.texto, super.key});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icone,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(texto, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
