import 'package:flutter/material.dart';

import '../../data/historico_models.dart';

class HistoricoTreinoCard extends StatelessWidget {
  const HistoricoTreinoCard({
    required this.treino,
    required this.onTap,
    super.key,
  });

  final HistoricoTreinoResumo treino;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      treino.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatarHora(treino.iniciadoEm)} → '
                '${_formatarHora(treino.finalizadoEm)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InformacaoCompacta(
                      icon: Icons.timer_outlined,
                      texto: _formatarDuracao(treino.duracao),
                    ),
                  ),
                  Expanded(
                    child: _InformacaoCompacta(
                      icon: Icons.fitness_center_outlined,
                      texto: '${treino.quantidadeExercicios} exercícios',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InformacaoCompacta(
                      icon: Icons.task_alt_outlined,
                      texto: '${treino.quantidadeSeries} séries',
                    ),
                  ),
                  Expanded(
                    child: _InformacaoCompacta(
                      icon: Icons.monitor_weight_outlined,
                      texto: _formatarVolume(treino.volumeTotalGramas),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatarHora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  static String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);

    if (horas == 0) {
      return '${minutos}min';
    }

    return '${horas}h${minutos.toString().padLeft(2, '0')}';
  }

  static String _formatarVolume(int volumeGramas) {
    final quilos = volumeGramas / 1000;

    if (quilos >= 1000) {
      return '${(quilos / 1000).toStringAsFixed(1)} t';
    }

    if (quilos == quilos.roundToDouble()) {
      return '${quilos.toInt()} kg';
    }

    return '${quilos.toStringAsFixed(1)} kg';
  }
}

class _InformacaoCompacta extends StatelessWidget {
  const _InformacaoCompacta({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
