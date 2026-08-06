import 'package:flutter/material.dart';

class BackupInfoCard extends StatelessWidget {
  const BackupInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Proteja seus dados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'O arquivo .gym inclui uma cópia consistente do banco e um '
              'manifesto com versões, data e quantidades de registros.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Após a criação, o compartilhamento do Android será aberto para '
              'você salvar no Drive, Arquivos ou outro destino.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
