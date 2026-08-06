import 'package:flutter/material.dart';

import '../../data/backup_info.dart';

class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({required this.info, super.key});

  final BackupInfo info;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: info.backupValido
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: info.backupValido
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              child: Icon(
                info.backupValido
                    ? Icons.verified_outlined
                    : Icons.schedule_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último backup',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.possuiBackup
                        ? _formatarDataHora(info.ultimoBackupEm!)
                        : 'Nunca realizado',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (info.nomeArquivo != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      info.nomeArquivo!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (info.tamanhoBytes != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatarTamanho(info.tamanhoBytes!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (info.possuiBackup) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                          icon: Icons.verified_outlined,
                          texto: info.backupValido
                              ? 'Backup válido'
                              : 'Verificação pendente',
                          destaque: info.backupValido,
                        ),
                        _StatusChip(
                          icon: info.compartilhado
                              ? Icons.cloud_done_outlined
                              : Icons.phone_android_outlined,
                          texto: info.compartilhado
                              ? 'Compartilhado'
                              : 'Salvo no aparelho',
                          destaque: info.compartilhado,
                        ),
                      ],
                    ),
                    if (info.compartilhadoEm != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Compartilhado em '
                        '${_formatarDataHora(info.compartilhadoEm!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  static String _formatarTamanho(int bytes) {
    if (bytes < 1024) {
      return '$bytes bytes';
    }

    final quilobytes = bytes / 1024;

    if (quilobytes < 1024) {
      return '${quilobytes.toStringAsFixed(1)} KB';
    }

    return '${(quilobytes / 1024).toStringAsFixed(1)} MB';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.texto,
    required this.destaque,
  });

  final IconData icon;
  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: destaque
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: destaque
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: destaque
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
