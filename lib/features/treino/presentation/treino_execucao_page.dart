import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/treino_realizado_dao.dart';
import 'widgets/cabecalho_treino.dart';
import 'widgets/descanso_bar.dart';
import 'widgets/exercicio_execucao_card.dart';
import 'treino_conclusao_page.dart';

class TreinoExecucaoPage extends StatefulWidget {
  const TreinoExecucaoPage({
    required this.database,
    required this.treinoRealizadoId,
    super.key,
  });

  final AppDatabase database;
  final int treinoRealizadoId;

  @override
  State<TreinoExecucaoPage> createState() => _TreinoExecucaoPageState();
}

class _TreinoExecucaoPageState extends State<TreinoExecucaoPage> {
  Timer? _timerTreino;
  Timer? _timerDescanso;

  DateTime _agora = DateTime.now();
  int _descansoRestante = 0;
  int _descansoTotal = 0;
  bool _descansoPausado = false;
  bool _finalizandoTreino = false;
  bool _resumoAutomaticoSolicitado = false;
  String? _descansoOrigem;

  AppDatabase get database => widget.database;

  int get treinoRealizadoId => widget.treinoRealizadoId;

  @override
  void initState() {
    super.initState();

    _timerTreino = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _agora = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timerTreino?.cancel();
    _timerDescanso?.cancel();
    super.dispose();
  }

  Future<void> _iniciarDescanso(SerieRealizada serie) async {
    final segundos = serie.descansoPlanejadoSegundos;

    final detalhes = await database.treinoRealizadoDao.listarSeriesDoTreino(
      treinoRealizadoId,
    );

    if (!mounted) {
      return;
    }

    final existeSeriePendente = detalhes.any(
      (detalhe) => detalhe.serie.situacao == 'pendente',
    );

    if (!existeSeriePendente) {
      _timerDescanso?.cancel();

      setState(() {
        _descansoRestante = 0;
        _descansoTotal = 0;
        _descansoPausado = false;
        _descansoOrigem = null;
      });

      return;
    }

    if (segundos <= 0) {
      return;
    }

    _timerDescanso?.cancel();

    setState(() {
      _descansoTotal = segundos;
      _descansoRestante = segundos;
      _descansoPausado = false;
      _descansoOrigem = 'Após a série ${serie.ordem}';
    });

    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _descansoPausado) {
        return;
      }

      if (_descansoRestante <= 1) {
        timer.cancel();
        HapticFeedback.heavyImpact();

        setState(() {
          _descansoRestante = 0;
        });

        return;
      }

      setState(() {
        _descansoRestante -= 1;
      });
    });
  }

  void _alternarPausaDescanso() {
    if (_descansoRestante <= 0) {
      return;
    }

    setState(() {
      _descansoPausado = !_descansoPausado;
    });
  }

  void _pularDescanso() {
    _timerDescanso?.cancel();

    setState(() {
      _descansoRestante = 0;
      _descansoPausado = false;
    });
  }

  Duration _calcularTempoDecorrido(DateTime iniciadoEm) {
    final diferenca = _agora.difference(iniciadoEm);

    if (diferenca.isNegative) {
      return Duration.zero;
    }

    return diferenca;
  }

  Future<void> _concluirTreinoEExibirResumo() async {
    if (_finalizandoTreino) {
      return;
    }

    setState(() {
      _finalizandoTreino = true;
    });

    try {
      final finalizado = await database.treinoRealizadoDao.finalizarTreino(
        treinoRealizadoId: treinoRealizadoId,
      );

      if (!mounted) {
        return;
      }

      if (!finalizado) {
        throw StateError('O treino não foi encontrado.');
      }

      _timerDescanso?.cancel();

      final resumo = await database.treinoRealizadoDao
          .obterResumoTreinoConcluido(treinoRealizadoId: treinoRealizadoId);

      if (!mounted) {
        return;
      }

      final voltarParaHome = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) {
            return TreinoConclusaoPage(resumo: resumo);
          },
        ),
      );

      if (!mounted) {
        return;
      }

      if (voltarParaHome == true) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _resumoAutomaticoSolicitado = false;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível finalizar o treino.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _finalizandoTreino = false;
        });
      }
    }
  }

  Future<void> _finalizarTreino() async {
    final detalhes = await database.treinoRealizadoDao.listarSeriesDoTreino(
      treinoRealizadoId,
    );

    if (!mounted) {
      return;
    }

    final pendentes = detalhes
        .where((detalhe) => detalhe.serie.situacao == 'pendente')
        .length;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar treino'),
          content: Text(
            pendentes == 0
                ? 'Todas as séries foram finalizadas. Deseja concluir o treino?'
                : 'Ainda existem $pendentes séries pendentes. '
                      'Elas serão registradas como puladas. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    await _concluirTreinoEExibirResumo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TreinoRealizado?>(
      future: database.treinoRealizadoDao.obterTreinoPorId(treinoRealizadoId),
      builder: (context, treinoSnapshot) {
        if (treinoSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Não foi possível carregar o treino.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!treinoSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final treino = treinoSnapshot.data;

        if (treino == null) {
          return const Scaffold(
            body: Center(child: Text('O treino não foi encontrado.')),
          );
        }

        return StreamBuilder<List<SerieTreinoDetalhe>>(
          stream: database.treinoRealizadoDao.observarSeriesDoTreino(
            treinoRealizadoId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text(treino.nomeFichaSnapshot)),
                body: const Center(
                  child: Text(
                    'Não foi possível carregar a execução do treino.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: Text(treino.nomeFichaSnapshot)),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final detalhes = snapshot.data!;
            final total = detalhes.length;
            final concluidas = detalhes
                .where((detalhe) => detalhe.serie.situacao == 'concluida')
                .length;

            final todasSeriesConcluidas = total > 0 && concluidas == total;

            if (todasSeriesConcluidas &&
                !_finalizandoTreino &&
                !_resumoAutomaticoSolicitado) {
              _resumoAutomaticoSolicitado = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }

                _concluirTreinoEExibirResumo();
              });
            }

            final primeiraPendente = detalhes
                .cast<SerieTreinoDetalhe?>()
                .firstWhere(
                  (detalhe) => detalhe?.serie.situacao == 'pendente',
                  orElse: () => null,
                );

            final grupos = <int, List<SerieTreinoDetalhe>>{};

            for (final detalhe in detalhes) {
              grupos.putIfAbsent(detalhe.exercicio.id, () => []).add(detalhe);
            }

            final exercicios =
                grupos.values.map((grupo) => grupo.first.exercicio).toList()
                  ..sort((a, b) => a.ordem.compareTo(b.ordem));

            return Scaffold(
              appBar: AppBar(
                title: Text(treino.nomeFichaSnapshot),
                actions: [
                  if (concluidas == total && total > 0)
                    TextButton.icon(
                      onPressed: _finalizandoTreino ? null : _finalizarTreino,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Finalizar'),
                    )
                  else
                    IconButton(
                      tooltip: 'Finalizar treino',
                      onPressed: _finalizandoTreino ? null : _finalizarTreino,
                      icon: const Icon(Icons.flag_outlined),
                    ),
                ],
              ),
              body: Column(
                children: [
                  CabecalhoTreino(
                    tempoDecorrido: _calcularTempoDecorrido(treino.iniciadoEm),
                    concluidas: concluidas,
                    total: total,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: exercicios.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum exercício foi copiado para este treino.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 112),
                            itemCount: exercicios.length,
                            separatorBuilder: (_, _) {
                              return const SizedBox(height: 8);
                            },
                            itemBuilder: (context, index) {
                              final exercicio = exercicios[index];
                              final series = grupos[exercicio.id]!;

                              final todasConcluidas = series.every(
                                (detalhe) =>
                                    detalhe.serie.situacao == 'concluida' ||
                                    detalhe.serie.situacao == 'pulada',
                              );

                              final atual = series.any(
                                (detalhe) =>
                                    detalhe.serie.id ==
                                    primeiraPendente?.serie.id,
                              );

                              final proximoExercicio =
                                  index + 1 < exercicios.length
                                  ? exercicios[index + 1]
                                  : null;

                              return ExercicioExecucaoCard(
                                database: database,
                                exercicio: exercicio,
                                series: series,
                                serieAtualId: primeiraPendente?.serie.id,
                                concluido: todasConcluidas,
                                atual: atual,
                                proximoExercicioNome:
                                    todasConcluidas && proximoExercicio != null
                                    ? proximoExercicio.nomeExercicioSnapshot
                                    : null,
                                onSerieConcluida: _iniciarDescanso,
                              );
                            },
                          ),
                  ),
                ],
              ),

              bottomNavigationBar: _descansoRestante > 0
                  ? DescansoBar(
                      restante: _descansoRestante,
                      total: _descansoTotal,
                      pausado: _descansoPausado,
                      origem: _descansoOrigem,
                      onPausar: _alternarPausaDescanso,
                      onPular: _pularDescanso,
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
