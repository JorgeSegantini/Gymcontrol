import 'package:flutter/material.dart';

import '../../../core/database/models/evolucao_exercicio.dart';
import '../../../core/database/models/resumo_treino_concluido.dart';

class TreinoConclusaoPage extends StatefulWidget {
  const TreinoConclusaoPage({required this.resumo, super.key});

  final ResumoTreinoConcluido resumo;

  @override
  State<TreinoConclusaoPage> createState() => _TreinoConclusaoPageState();
}

class _TreinoConclusaoPageState extends State<TreinoConclusaoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  ResumoTreinoConcluido get resumo => widget.resumo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensagem = _mensagemMotivacional(resumo.evolucoes.length);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Treino concluído'),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _CabecalhoConclusao(
                    nomeTreino: resumo.nomeTreino,
                    mensagem: mensagem,
                    quantidadeEvolucoes: resumo.evolucoes.length,
                  ),
                  const SizedBox(height: 16),
                  _ResumoTreinoCard(resumo: resumo),
                  if (resumo.evolucoes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _EvolucoesCard(evolucoes: resumo.evolucoes),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text(
                        'VOLTAR PARA HOME',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _mensagemMotivacional(int evolucoes) {
    if (evolucoes >= 3) {
      return 'Excelente sessão! Você evoluiu em vários exercícios hoje.';
    }

    if (evolucoes > 0) {
      return 'Boa evolução hoje. Continue consistente.';
    }

    return 'Treino concluído com consistência.';
  }
}

class _CabecalhoConclusao extends StatelessWidget {
  const _CabecalhoConclusao({
    required this.nomeTreino,
    required this.mensagem,
    required this.quantidadeEvolucoes,
  });

  final String nomeTreino;
  final String mensagem;
  final int quantidadeEvolucoes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 42,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TREINO CONCLUÍDO',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 10),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            if (quantidadeEvolucoes > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  quantidadeEvolucoes == 1
                      ? '1 evolução registrada'
                      : '$quantidadeEvolucoes evoluções registradas',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResumoTreinoCard extends StatelessWidget {
  const _ResumoTreinoCard({required this.resumo});

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
                  'Resumo do treino',
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
      final toneladas = quilos / 1000;
      return '${toneladas.toStringAsFixed(1)} t';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25),
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

class _EvolucoesCard extends StatelessWidget {
  const _EvolucoesCard({required this.evolucoes});

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
                  'Evoluções do treino',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < evolucoes.length; index++) ...[
              _EvolucaoItem(evolucao: evolucoes[index]),
              if (index < evolucoes.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _EvolucaoItem extends StatelessWidget {
  const _EvolucaoItem({required this.evolucao});

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
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 110),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          diferencas.isEmpty ? 'Evolução' : diferencas.join(' • '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: colorScheme.onTertiaryContainer,
          ),
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
