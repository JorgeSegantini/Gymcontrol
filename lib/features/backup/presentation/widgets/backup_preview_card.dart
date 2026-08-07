import 'package:flutter/material.dart';

import '../../data/backup_selecionado.dart';

class BackupPreviewCard extends StatelessWidget {
  const BackupPreviewCard({required this.backup, super.key});

  final BackupSelecionado backup;

  @override
  Widget build(BuildContext context) {
    final manifesto = backup.manifesto;
    final estatisticas = manifesto.estatisticas;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.verified_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup válido',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        backup.nomeArquivo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Linha(
              rotulo: 'Criado em',
              valor: _formatarDataHora(manifesto.criadoEm),
            ),
            _Linha(
              rotulo: 'Tamanho',
              valor: _formatarTamanho(backup.tamanhoBytes),
            ),
            _Linha(
              rotulo: 'Versão do aplicativo',
              valor: manifesto.versaoAplicativo,
            ),
            _Linha(rotulo: 'Banco', valor: 'Schema ${manifesto.versaoBanco}'),
            _Linha(
              rotulo: 'Biblioteca',
              valor: manifesto.versaoBiblioteca == null
                  ? 'Não informada'
                  : 'Versão ${manifesto.versaoBiblioteca}',
            ),
            const Divider(height: 24),
            Text(
              'Conteúdo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _Linha(
              rotulo: 'Treinos realizados',
              valor: '${estatisticas.treinosRealizados}',
            ),
            _Linha(
              rotulo: 'Séries realizadas',
              valor: '${estatisticas.seriesRealizadas}',
            ),
            _Linha(
              rotulo: 'Fichas de treino',
              valor: '${estatisticas.fichasTreino}',
            ),
            _Linha(
              rotulo: 'Planos de treino',
              valor: '${estatisticas.planosTreino}',
            ),
            _Linha(rotulo: 'Exercícios', valor: '${estatisticas.exercicios}'),
          ],
        ),
      ),
    );
  }

  static String _formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');

    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        'às ${dois(data.hour)}:${dois(data.minute)}';
  }

  static String _formatarTamanho(int bytes) {
    final quilobytes = bytes / 1024;

    if (quilobytes < 1024) {
      return '${quilobytes.toStringAsFixed(1)} KB';
    }

    return '${(quilobytes / 1024).toStringAsFixed(1)} MB';
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(rotulo, style: TextStyle(color: color)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
