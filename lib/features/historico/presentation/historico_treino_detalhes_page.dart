import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/models/evolucao_exercicio.dart';
import '../../../core/database/models/resumo_treino_concluido.dart';
import '../data/historico_models.dart';
import '../data/historico_service.dart';
import 'widgets/historico_exercicio_card.dart';

class HistoricoTreinoDetalhesPage extends StatelessWidget {
  const HistoricoTreinoDetalhesPage({
    required this.database,
    required this.treinoRealizadoId,
    super.key,
  });

  final AppDatabase database;
  final int treinoRealizadoId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoricoTreinoDetalhes>(
      future: _carregarDetalhes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes do treino')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes do treino')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Não foi possível carregar os detalhes do treino.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final detalhes = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(detalhes.resumo.nomeTreino)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _CabecalhoHistorico(
                nomeTreino: detalhes.resumo.nomeTreino,
                data: detalhes.data,
              ),
              const SizedBox(height: 16),
              _ResumoHistoricoCard(resumo: detalhes.resumo),
              if (detalhes.resumo.evolucoes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _EvolucoesHistoricoCard(evolucoes: detalhes.resumo.evolucoes),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.fitness_center_outlined),
                  const SizedBox(width: 10),
                  Text(
                    'Exercícios e séries',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (detalhes.exercicios.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Nenhum exercício foi registrado neste treino.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final exercicio in detalhes.exercicios) ...[
                  HistoricoExercicioCard(exercicio: exercicio),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        );
      },
    );
  }

  Future<_HistoricoTreinoDetalhes> _carregarDetalhes() async {
    final treino = await database.treinoRealizadoDao.obterTreinoPorId(
      treinoRealizadoId,
    );

    if (treino == null) {
      throw StateError('O treino não foi encontrado.');
    }

    final resumo = await database.treinoRealizadoDao.obterResumoTreinoConcluido(
      treinoRealizadoId: treinoRealizadoId,
    );

    final exercicios = await HistoricoService(
      database,
    ).listarExerciciosDoTreino(treinoRealizadoId);

    return _HistoricoTreinoDetalhes(
      resumo: resumo,
      data: treino.finalizadoEm ?? treino.iniciadoEm,
      exercicios: exercicios,
    );
  }
}

class _HistoricoTreinoDetalhes {
  const _HistoricoTreinoDetalhes({
    required this.resumo,
    required this.data,
    required this.exercicios,
  });

  final ResumoTreinoConcluido resumo;
  final DateTime data;
  final List<HistoricoExercicioDetalhe> exercicios;
}

class _CabecalhoHistorico extends StatelessWidget {
  const _CabecalhoHistorico({required this.nomeTreino, required this.data});

  final String nomeTreino;
  final DateTime data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_outlined,
                size: 34,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              nomeTreino,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatarData(data),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} • $hora:$minuto';
  }
}

class _ResumoHistoricoCard extends StatelessWidget {
  const _ResumoHistoricoCard({required this.resumo});

  final ResumoTreinoConcluido resumo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.insights_outlined),
                const SizedBox(width: 10),
                Text(
                  'Resumo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.timer_outlined,
                    valor: _formatarDuracao(resumo.duracao),
                    rotulo: 'Duração',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.monitor_weight_outlined,
                    valor: _formatarVolume(resumo.volumeTotalGramas),
                    rotulo: 'Volume',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.fitness_center_outlined,
                    valor: '${resumo.quantidadeExercicios}',
                    rotulo: 'Exercícios',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumoItem(
                    icon: Icons.task_alt_outlined,
                    valor: '${resumo.quantidadeSeries}',
                    rotulo: 'Séries',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EvolucoesHistoricoCard extends StatelessWidget {
  const _EvolucoesHistoricoCard({required this.evolucoes});

  final List<EvolucaoExercicio> evolucoes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: colorScheme.tertiary),
                const SizedBox(width: 10),
                Text(
                  'Evoluções',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < evolucoes.length; index++) ...[
              _EvolucaoHistoricoItem(evolucao: evolucoes[index]),
              if (index < evolucoes.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _EvolucaoHistoricoItem extends StatelessWidget {
  const _EvolucaoHistoricoItem({required this.evolucao});

  final EvolucaoExercicio evolucao;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diferencas = <String>[];

    if (evolucao.diferencaCargaGramas > 0) {
      diferencas.add('+${_formatarCarga(evolucao.diferencaCargaGramas)}');
    }

    if (evolucao.diferencaRepeticoes > 0) {
      diferencas.add('+${evolucao.diferencaRepeticoes} rep');
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        child: const Icon(Icons.trending_up_rounded),
      ),
      title: Text(
        evolucao.nomeExercicio,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${_formatarCarga(evolucao.cargaAtualGramas)} × '
        '${evolucao.repeticoesAtuais}',
      ),
      trailing: Text(
        diferencas.isEmpty ? 'Evolução' : diferencas.join(' • '),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: colorScheme.tertiary,
        ),
      ),
    );
  }

  static String _formatarCarga(int cargaGramas) {
    final quilos = cargaGramas / 1000;

    if (quilos == quilos.roundToDouble()) {
      return '${quilos.toInt()} kg';
    }

    return '${quilos.toStringAsFixed(1)} kg';
  }
}
