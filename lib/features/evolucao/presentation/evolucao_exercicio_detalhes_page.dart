import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/evolucao_models.dart';
import '../data/evolucao_service.dart';

class EvolucaoExercicioDetalhesPage extends StatelessWidget {
  const EvolucaoExercicioDetalhesPage({
    required this.database,
    required this.exercicio,
    super.key,
  });

  final AppDatabase database;
  final EvolucaoExercicioResumo exercicio;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EvolucaoExercicioDetalhes>(
      future: EvolucaoService(database).obterDetalhesExercicio(
        exercicioOrigemId: exercicio.exercicioOrigemId,
        nomeExercicio: exercicio.nome,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(exercicio.nome)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(exercicio.nome)),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Não foi possível carregar a evolução deste exercício.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final detalhes = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(detalhes.nome)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _CabecalhoExercicio(detalhes: detalhes),
              const SizedBox(height: 16),
              _UltimaExecucaoCard(execucao: detalhes.ultimaExecucao),
              const SizedBox(height: 16),
              _PainelRecordes(detalhes: detalhes),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.history_outlined),
                  const SizedBox(width: 10),
                  Text(
                    'Histórico do exercício',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (
                var index = 0;
                index < detalhes.execucoes.length;
                index++
              ) ...[
                _ExecucaoTimelineCard(execucao: detalhes.execucoes[index]),
                if (index < detalhes.execucoes.length - 1)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CabecalhoExercicio extends StatelessWidget {
  const _CabecalhoExercicio({required this.detalhes});

  final EvolucaoExercicioDetalhes detalhes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tendencia = _dadosTendencia(detalhes.tendencia);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.trending_up_rounded, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              detalhes.nome,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detalhes.quantidadeExecucoes == 1
                  ? '1 treino realizado'
                  : '${detalhes.quantidadeExecucoes} treinos realizados',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tendencia.icon,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tendencia.texto,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ({IconData icon, String texto}) _dadosTendencia(
    TendenciaExercicio tendencia,
  ) {
    return switch (tendencia) {
      TendenciaExercicio.evoluindo => (
        icon: Icons.trending_up_rounded,
        texto: 'Evoluindo',
      ),
      TendenciaExercicio.estavel => (
        icon: Icons.trending_flat_rounded,
        texto: 'Estável',
      ),
      TendenciaExercicio.atencao => (
        icon: Icons.trending_down_rounded,
        texto: 'Última execução abaixo da anterior',
      ),
      TendenciaExercicio.insuficiente => (
        icon: Icons.hourglass_empty_outlined,
        texto: 'Aguardando mais execuções',
      ),
    };
  }
}

class _UltimaExecucaoCard extends StatelessWidget {
  const _UltimaExecucaoCard({required this.execucao});

  final EvolucaoExecucaoItem execucao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Última execução',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatarCarga(execucao.maiorCargaGramas)} × '
              '${execucao.maiorRepeticao}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'RIR ${execucao.rir ?? '—'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatarData(execucao.data)} • ${execucao.nomeTreino}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainelRecordes extends StatelessWidget {
  const _PainelRecordes({required this.detalhes});

  final EvolucaoExercicioDetalhes detalhes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RecordeCard(
                icon: Icons.fitness_center_outlined,
                titulo: 'Maior carga',
                valor: _formatarCarga(detalhes.maiorCarga.valor),
                data: detalhes.maiorCarga.data,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RecordeCard(
                icon: Icons.repeat_rounded,
                titulo: 'Maior repetição',
                valor: '${detalhes.maiorRepeticao.valor}',
                data: detalhes.maiorRepeticao.data,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _RecordeCard(
                icon: Icons.monitor_weight_outlined,
                titulo: 'Maior volume',
                valor: _formatarVolume(detalhes.maiorVolume.valor),
                data: detalhes.maiorVolume.data,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RecordeCard(
                icon: Icons.event_available_outlined,
                titulo: 'Primeira execução',
                valor: _formatarData(detalhes.primeiraExecucao),
                data: detalhes.primeiraExecucao,
                mostrarDataAbaixo: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordeCard extends StatelessWidget {
  const _RecordeCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.data,
    this.mostrarDataAbaixo = true,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final DateTime data;
  final bool mostrarDataAbaixo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (mostrarDataAbaixo) ...[
              const SizedBox(height: 4),
              Text(
                '🏆 ${_formatarData(data)}',
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExecucaoTimelineCard extends StatelessWidget {
  const _ExecucaoTimelineCard({required this.execucao});

  final EvolucaoExecucaoItem execucao;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 48,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    execucao.data.day.toString().padLeft(2, '0'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _nomeMesCurto(execucao.data.month),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatarCarga(execucao.maiorCargaGramas)} × '
                          '${execucao.maiorRepeticao}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (execucao.possuiRecorde)
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 20,
                          color: colorScheme.tertiary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'RIR ${execucao.rir ?? '—'}'
                    ' • Volume ${_formatarVolume(execucao.volumeTotalGramas)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    execucao.nomeTreino,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _nomeMesCurto(int mes) {
    return const [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ][mes - 1];
  }
}

String _formatarCarga(int cargaGramas) {
  final quilos = cargaGramas / 1000;

  if (quilos == quilos.roundToDouble()) {
    return '${quilos.toInt()} kg';
  }

  return '${quilos.toStringAsFixed(1)} kg';
}

String _formatarVolume(int volumeGramas) {
  final quilos = volumeGramas / 1000;

  if (quilos >= 1000) {
    return '${(quilos / 1000).toStringAsFixed(1)} t';
  }

  if (quilos == quilos.roundToDouble()) {
    return '${quilos.toInt()} kg';
  }

  return '${quilos.toStringAsFixed(1)} kg';
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');

  return '$dia/$mes/${data.year}';
}
