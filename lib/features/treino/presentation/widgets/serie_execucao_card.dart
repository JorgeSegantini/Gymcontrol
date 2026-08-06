import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/serie_ultima_execucao.dart';
import 'controle_numerico.dart';

class SerieExecucaoCard extends StatefulWidget {
  const SerieExecucaoCard({
    required this.database,
    required this.serie,
    required this.anterior,
    required this.destacada,
    required this.centralizarAoDestacar,
    required this.onConcluida,
    super.key,
  });

  final AppDatabase database;
  final SerieRealizada serie;
  final SerieUltimaExecucao? anterior;
  final bool destacada;
  final bool centralizarAoDestacar;
  final Future<void> Function(SerieRealizada) onConcluida;

  @override
  State<SerieExecucaoCard> createState() => _SerieExecucaoCardState();
}

class _SerieExecucaoCardState extends State<SerieExecucaoCard> {
  late int _cargaGramas;
  late int _repeticoes;
  late int _rir;
  late bool _expandida;
  late bool _concluidaLocal;
  late bool _mostrarUltimaExecucao;
  bool _salvando = false;

  SerieRealizada get serie => widget.serie;

  bool get _concluida => _concluidaLocal || serie.situacao == 'concluida';

  int get _incrementoCarga {
    final incremento = serie.incrementoCargaGramas;

    if (incremento == null || incremento <= 0) {
      return 2500;
    }

    return incremento;
  }

  @override
  void initState() {
    super.initState();
    _concluidaLocal = widget.serie.situacao == 'concluida';
    _expandida = widget.destacada && !_concluida;
    _mostrarUltimaExecucao = !_concluida;
    _carregarValores();

    if (widget.destacada && !_concluida && widget.centralizarAoDestacar) {
      _centralizarSerieAtual();
    }
  }

  @override
  void didUpdateWidget(covariant SerieExecucaoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.serie.atualizadoEm != widget.serie.atualizadoEm) {
      _concluidaLocal = widget.serie.situacao == 'concluida';
      _carregarValores();
    }

    if (!oldWidget.destacada && widget.destacada && !_concluida) {
      _expandida = true;
      _mostrarUltimaExecucao = true;

      if (widget.centralizarAoDestacar) {
        _centralizarSerieAtual();
      }
    }

    if (!_concluida && oldWidget.destacada && !widget.destacada) {
      _expandida = false;
    }
  }

  void _centralizarSerieAtual() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !widget.destacada) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (!mounted || !widget.destacada) {
        return;
      }

      await Scrollable.ensureVisible(
        context,
        alignment: 0,
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeInOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  void _carregarValores() {
    _cargaGramas =
        serie.cargaRealizadaGramas ?? serie.cargaPlanejadaGramas ?? 0;
    _repeticoes =
        serie.repeticoesRealizadas ??
        serie.repeticoesMinimasPlanejadas ??
        serie.repeticoesMaximasPlanejadas ??
        0;
    _rir = (serie.rirRealizado ?? 0).clamp(0, 4).toInt();
  }

  void _alterarCarga(int diferenca) {
    if (_concluida || _salvando) {
      return;
    }

    setState(() {
      _cargaGramas = (_cargaGramas + diferenca).clamp(0, 1000000).toInt();
    });
  }

  void _alterarRepeticoes(int diferenca) {
    if (_concluida || _salvando) {
      return;
    }

    setState(() {
      _repeticoes = (_repeticoes + diferenca).clamp(0, 999).toInt();
    });
  }

  Future<void> _concluirSerie() async {
    if (_concluida || _salvando) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final concluida = await widget.database.treinoRealizadoDao.concluirSerie(
        id: serie.id,
        cargaRealizadaGramas: _cargaGramas,
        repeticoesRealizadas: _repeticoes,
        rirRealizado: _rir,
      );

      if (!mounted) {
        return;
      }

      if (!concluida) {
        throw StateError('A série realizada não foi encontrada.');
      }

      await HapticFeedback.mediumImpact();

      if (!mounted) {
        return;
      }

      setState(() {
        _concluidaLocal = true;
        _expandida = false;
        _mostrarUltimaExecucao = false;
      });

      await widget.onConcluida(serie);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Série ${serie.ordem} concluída.')),
        );
    } on ArgumentError catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              erro.message?.toString() ?? 'Não foi possível concluir a série.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível concluir a série.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cor = _concluida
        ? Colors.green.withValues(alpha: 0.10)
        : widget.destacada
        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
        : colorScheme.surfaceContainerLow;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: cor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.destacada && !_concluida
            ? BorderSide(color: colorScheme.primary, width: 2.5)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expandida = !_expandida;

                if (_concluida) {
                  _mostrarUltimaExecucao = _expandida;
                } else {
                  _mostrarUltimaExecucao = true;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 44,
                              ),
                              child: Text(
                                '${_formatarCarga(_cargaGramas)} × '
                                '$_repeticoes • RIR $_rir',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _concluida
                                        ? Colors.green.withValues(alpha: 0.18)
                                        : colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${serie.ordem}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _concluida
                                              ? Colors.green.shade800
                                              : colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.anterior != null &&
                            _mostrarUltimaExecucao) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          Text(
                            'Última execução',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_formatarCarga(widget.anterior!.cargaGramas)} × '
                            '${widget.anterior!.repeticoes ?? '—'}'
                            ' • RIR ${widget.anterior!.rir ?? '—'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expandida ? Icons.expand_less : Icons.expand_more,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expandida
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12),
                  ControleNumerico(
                    rotulo: 'Peso',
                    valor: _formatarCarga(_cargaGramas),
                    textoMenos: '-${_formatarCargaCurta(_incrementoCarga)}',
                    textoMais: '+${_formatarCargaCurta(_incrementoCarga)}',
                    habilitado: !_concluida && !_salvando,
                    onDiminuir: () {
                      _alterarCarga(-_incrementoCarga);
                    },
                    onAumentar: () {
                      _alterarCarga(_incrementoCarga);
                    },
                  ),
                  const SizedBox(height: 8),
                  ControleNumerico(
                    rotulo: 'Repetições',
                    valor: '$_repeticoes',
                    textoMenos: '−',
                    textoMais: '+',
                    habilitado: !_concluida && !_salvando,
                    onDiminuir: () {
                      _alterarRepeticoes(-1);
                    },
                    onAumentar: () {
                      _alterarRepeticoes(1);
                    },
                  ),
                  if (_textoFaixaPlanejada() != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          _textoFaixaPlanejada()!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Text(
                        'RIR',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var rir = 0; rir <= 4; rir++)
                              ChoiceChip(
                                label: Text('$rir'),
                                selected: _rir == rir,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onSelected: _concluida || _salvando
                                    ? null
                                    : (_) {
                                        setState(() {
                                          _rir = rir;
                                        });
                                      },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _concluida || _salvando
                          ? null
                          : _concluirSerie,
                      icon: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _concluida
                                  ? Icons.check
                                  : Icons.check_circle_outline,
                            ),
                      label: Text(
                        _concluida ? '✓ CONCLUÍDA' : 'Concluir série',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _textoFaixaPlanejada() {
    final minimo = serie.repeticoesMinimasPlanejadas;
    final maximo = serie.repeticoesMaximasPlanejadas;

    if (minimo == null && maximo == null) {
      return null;
    }

    if (minimo != null && maximo != null && minimo != maximo) {
      return 'Mín. $minimo  •  Máx. $maximo';
    }

    final valor = minimo ?? maximo;

    return 'Planejado: $valor rep';
  }

  static String _formatarCarga(int? cargaGramas) {
    if (cargaGramas == null) {
      return '—';
    }

    final cargaQuilos = cargaGramas / 1000;

    if (cargaQuilos == cargaQuilos.roundToDouble()) {
      return '${cargaQuilos.toInt()} kg';
    }

    return '${cargaQuilos.toStringAsFixed(1)} kg';
  }

  static String _formatarCargaCurta(int cargaGramas) {
    final cargaQuilos = cargaGramas / 1000;

    if (cargaQuilos == cargaQuilos.roundToDouble()) {
      return '${cargaQuilos.toInt()}';
    }

    return cargaQuilos.toStringAsFixed(1);
  }
}
