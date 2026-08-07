import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/serie_ultima_execucao.dart';
import '../../../../core/database/treino_realizado_dao.dart';
import '../../../exercicios/presentation/exercicio_detalhes_page.dart';
import 'serie_execucao_card.dart';

class ExercicioExecucaoCard extends StatefulWidget {
  const ExercicioExecucaoCard({
    required this.database,
    required this.exercicio,
    required this.series,
    required this.serieAtualId,
    required this.concluido,
    required this.atual,
    required this.proximoExercicioNome,
    required this.onSerieConcluida,
    super.key,
  });

  final AppDatabase database;
  final ExercicioRealizado exercicio;
  final List<SerieTreinoDetalhe> series;
  final int? serieAtualId;
  final bool concluido;
  final bool atual;
  final String? proximoExercicioNome;
  final Future<void> Function(SerieRealizada) onSerieConcluida;

  @override
  State<ExercicioExecucaoCard> createState() => _ExercicioExecucaoCardState();
}

class _ExercicioExecucaoCardState extends State<ExercicioExecucaoCard> {
  final ExpansibleController _expansionController = ExpansibleController();

  Future<List<SerieUltimaExecucao>>? _seriesAnterioresFuture;

  @override
  void initState() {
    super.initState();
    _carregarSeriesAnteriores();
  }

  @override
  void didUpdateWidget(covariant ExercicioExecucaoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.exercicio.exercicioOrigemId !=
        widget.exercicio.exercicioOrigemId) {
      _carregarSeriesAnteriores();
    }

    if (!oldWidget.atual && widget.atual) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.atual) {
          _expansionController.expand();
        }
      });

      if (widget.exercicio.ordem > 1) {
        _centralizarExercicioAtual();
      }
    }

    if (!oldWidget.concluido && widget.concluido) {
      Future<void>.delayed(const Duration(milliseconds: 2200), () {
        if (mounted && widget.concluido && !widget.atual) {
          _expansionController.collapse();
        }
      });
    }
  }

  void _centralizarExercicioAtual() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !widget.atual) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (!mounted || !widget.atual) {
        return;
      }

      await Scrollable.ensureVisible(
        context,
        alignment: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  void _carregarSeriesAnteriores() {
    final exercicioOrigemId = widget.exercicio.exercicioOrigemId;

    _seriesAnterioresFuture = exercicioOrigemId == null
        ? Future<List<SerieUltimaExecucao>>.value(const [])
        : widget.database.treinoRealizadoDao.obterSeriesUltimaExecucaoExercicio(
            exercicioOrigemId: exercicioOrigemId,
          );
  }

  int get _seriesConcluidas {
    return widget.series.where((detalhe) {
      final situacao = detalhe.serie.situacao;
      return situacao == 'concluida' || situacao == 'pulada';
    }).length;
  }

  Future<void> _abrirDetalhesExercicio() async {
    final exercicioOrigemId = widget.exercicio.exercicioOrigemId;

    if (exercicioOrigemId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercicioDetalhesPage(
          database: widget.database,
          exercicioId: exercicioOrigemId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<SerieUltimaExecucao>>(
      future: _seriesAnterioresFuture,
      builder: (context, snapshot) {
        final anterioresPorOrdem = <int, SerieUltimaExecucao>{
          for (final anterior in snapshot.data ?? const <SerieUltimaExecucao>[])
            anterior.ordem: anterior,
        };

        return Card(
          color: widget.concluido
              ? Colors.green.withValues(alpha: 0.12)
              : widget.atual
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : null,
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: ValueKey(widget.exercicio.id),
            controller: _expansionController,
            initiallyExpanded: widget.atual || widget.exercicio.ordem == 1,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: EdgeInsets.zero,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: widget.concluido
                      ? Colors.green
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: widget.concluido
                      ? const Icon(Icons.check, size: 18)
                      : Text(
                          '${widget.exercicio.ordem}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.exercicio.nomeExercicioSnapshot,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: widget.concluido
                              ? Colors.green.withValues(alpha: 0.16)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_seriesConcluidas/${widget.series.length}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: widget.concluido
                                    ? Colors.green.shade800
                                    : colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.exercicio.exercicioOrigemId != null)
                  IconButton(
                    tooltip: 'Informações do exercício',
                    visualDensity: VisualDensity.compact,
                    onPressed: _abrirDetalhesExercicio,
                    icon: const Icon(Icons.info_outline, size: 21),
                  ),
              ],
            ),
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  children: [
                    for (final detalhe in widget.series)
                      SerieExecucaoCard(
                        key: ValueKey(
                          '${detalhe.serie.id}-'
                          '${detalhe.serie.id == widget.serieAtualId}',
                        ),
                        database: widget.database,
                        serie: detalhe.serie,
                        anterior: anterioresPorOrdem[detalhe.serie.ordem],
                        destacada: detalhe.serie.id == widget.serieAtualId,
                        centralizarAoDestacar: detalhe.serie.ordem > 1,
                        onConcluida: widget.onSerieConcluida,
                      ),
                    if (widget.proximoExercicioNome != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_forward, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Próximo: ${widget.proximoExercicioNome}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
