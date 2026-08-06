import 'package:flutter/material.dart';

import '../../data/home_dashboard_models.dart';

class HomeResumoSemanal extends StatelessWidget {
  const HomeResumoSemanal({required this.resumo, super.key});

  final HomeResumoSemana resumo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta semana',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${_formatarData(resumo.inicioSemana)} – '
                  '${_formatarData(resumo.fimPeriodo)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.fitness_center_outlined,
                    valor: '${resumo.quantidadeTreinos}',
                    rotulo: resumo.quantidadeTreinos == 1
                        ? 'treino'
                        : 'treinos',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.timer_outlined,
                    valor: _formatarDuracao(resumo.duracaoTotal),
                    rotulo: 'treinados',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.task_alt_outlined,
                    valor: '${resumo.etapasConcluidas}',
                    rotulo: resumo.etapasConcluidas == 1 ? 'etapa' : 'etapas',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);

    if (horas == 0) {
      return '${minutos}min';
    }

    return '${horas}h${minutos.toString().padLeft(2, '0')}';
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes';
  }
}

class _ResumoItem extends StatelessWidget {
  const _ResumoItem({
    required this.icon,
    required this.valor,
    required this.rotulo,
  });

  final IconData icon;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
