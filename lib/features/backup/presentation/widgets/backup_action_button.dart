import 'package:flutter/material.dart';

class BackupActionButton extends StatelessWidget {
  const BackupActionButton({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onPressed,
    this.destaque = false,
    super.key,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onPressed;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: destaque ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: destaque
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: destaque
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
}
