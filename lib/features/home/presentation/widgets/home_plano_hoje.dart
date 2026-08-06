import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/plano_treino_dao.dart';

class HomePlanoHojeCard extends StatelessWidget {
  const HomePlanoHojeCard({
    required this.estado,
    required this.onIniciarTreino,
    required this.onConcluirEtapa,
    required this.onAbrirPlanos,
    super.key,
  });

  final EstadoPlanoAtual estado;
  final VoidCallback onIniciarTreino;
  final VoidCallback onConcluirEtapa;
  final VoidCallback onAbrirPlanos;

  @override
  Widget build(BuildContext context) {
    final item = estado.itemAtual!;
    final proximo = estado.proximoItem;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconeTipo(item.tipo),
                  size: 26,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Próxima etapa',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onAbrirPlanos,
                  child: const Text('Plano'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.codigo?.trim().isNotEmpty == true
                        ? item.codigo!.trim()
                        : '${item.ordem + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSecondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nome,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nomeTipo(item.tipo),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (item.descricao?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.descricao!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: item.tipo == TipoPlanoTreinoItem.treino.name
                    ? onIniciarTreino
                    : onConcluirEtapa,
                icon: Icon(
                  item.tipo == TipoPlanoTreinoItem.treino.name
                      ? Icons.play_arrow_rounded
                      : Icons.check_circle_outline,
                ),
                label: Text(_textoBotao(item.tipo)),
              ),
            ),
            if (proximo != null) ...[
              const SizedBox(height: 12),
              Text(
                'Depois: '
                '${proximo.codigo?.trim().isNotEmpty == true ? '${proximo.codigo} • ' : ''}'
                '${proximo.nome}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _textoBotao(String tipo) {
    return switch (tipo) {
      'treino' => 'Iniciar treino',
      'descanso' => 'Descanso concluído',
      'cardio' => 'Concluir cardio',
      'mobilidade' => 'Concluir mobilidade',
      'personalizado' => 'Concluir etapa',
      _ => 'Concluir etapa',
    };
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

  static String _nomeTipo(String tipo) {
    return switch (tipo) {
      'treino' => 'Treino',
      'descanso' => 'Descanso',
      'cardio' => 'Cardio',
      'mobilidade' => 'Mobilidade',
      'personalizado' => 'Personalizado',
      _ => tipo,
    };
  }
}

class HomeSemPlanoAtivoCard extends StatelessWidget {
  const HomeSemPlanoAtivoCard({
    required this.onAbrirPlanos,
    required this.onEscolherFicha,
    super.key,
  });

  final VoidCallback onAbrirPlanos;
  final VoidCallback onEscolherFicha;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nenhum plano ativo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ative um plano para receber a sugestão da próxima etapa.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onAbrirPlanos,
                    child: const Text('Escolher plano'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEscolherFicha,
                    child: const Text('Treinar agora'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomePlanoErroCard extends StatelessWidget {
  const HomePlanoErroCard({required this.onAbrirPlanos, super.key});

  final VoidCallback onAbrirPlanos;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Não foi possível carregar o plano ativo'),
        subtitle: const Text('Abra os planos e tente novamente.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onAbrirPlanos,
      ),
    );
  }
}
