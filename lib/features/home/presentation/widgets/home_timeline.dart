import 'package:flutter/material.dart';

import '../../data/home_dashboard_models.dart';

class HomeTimeline extends StatelessWidget {
  const HomeTimeline({required this.itens, required this.onItemTap, super.key});

  final List<HomeTimelineItem> itens;
  final ValueChanged<HomeTimelineItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linha do plano',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (var indice = 0; indice < itens.length; indice++)
              _TimelineItemView(
                item: itens[indice],
                ultimo: indice == itens.length - 1,
                onTap: () {
                  onItemTap(itens[indice]);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItemView extends StatelessWidget {
  const _TimelineItemView({
    required this.item,
    required this.ultimo,
    required this.onTap,
  });

  final HomeTimelineItem item;
  final bool ultimo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final atual = item.etapa == HomeTimelineEtapa.atual;
    final concluida = item.etapa == HomeTimelineEtapa.anterior;
    final cor = atual
        ? colorScheme.primary
        : concluida
        ? colorScheme.tertiary
        : colorScheme.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: atual ? cor : colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: cor, width: 2),
                    ),
                    child: Icon(
                      concluida
                          ? Icons.check_rounded
                          : atual
                          ? Icons.circle
                          : Icons.schedule_outlined,
                      size: atual ? 10 : 14,
                      color: atual ? colorScheme.onPrimary : cor,
                    ),
                  ),
                  if (!ultimo)
                    Container(
                      width: 2,
                      height: 46,
                      color: colorScheme.outlineVariant,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_iconeTipo(item.tipo), size: 22, color: cor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rotuloEtapa(item.etapa),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: cor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.identificacao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (item.descricao?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.descricao!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatarData(item.data),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: atual ? FontWeight.w800 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _rotuloEtapa(HomeTimelineEtapa etapa) {
    return switch (etapa) {
      HomeTimelineEtapa.anterior => 'Concluída',
      HomeTimelineEtapa.atual => 'Hoje',
      HomeTimelineEtapa.proxima => 'Próxima',
    };
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes';
  }

  static IconData _iconeTipo(String tipo) {
    return switch (tipo) {
      'treino' => Icons.fitness_center_outlined,
      'descanso' => Icons.bedtime_outlined,
      'cardio' => Icons.directions_run_outlined,
      'mobilidade' => Icons.self_improvement_outlined,
      'personalizado' => Icons.tune_outlined,
      _ => Icons.category_outlined,
    };
  }
}
