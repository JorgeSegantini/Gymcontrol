import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/ficha_treino_dao.dart';
import 'ficha_exercicio_serie_editor_page.dart';
import 'widgets/cabecalho_exercicio.dart';
import 'widgets/estado_vazio_series.dart';
import 'widgets/serie_card.dart';

class FichaExercicioEditorPage extends StatelessWidget {
  const FichaExercicioEditorPage({
    required this.database,
    required this.detalhe,
    super.key,
  });

  final AppDatabase database;
  final FichaExercicioDetalhe detalhe;

  Future<void> _adicionarSerie(BuildContext context) async {
    try {
      await database.fichaTreinoDao.adicionarSerie(
        fichaExercicioId: detalhe.fichaExercicio.id,
        copiarUltimaSerie: true,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Série adicionada ao exercício.')),
        );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_mensagemDaExcecao(erro.message))),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível adicionar a série.')),
        );
    }
  }

  Future<void> _duplicarSerie(
    BuildContext context,
    FichaExercicioSerie serie,
  ) async {
    try {
      await database.fichaTreinoDao.duplicarSerie(id: serie.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Série duplicada com sucesso.')),
        );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_mensagemDaExcecao(erro.message))),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível duplicar a série.')),
        );
    }
  }

  Future<void> _alterarSituacaoSerie(
    BuildContext context,
    FichaExercicioSerie serie,
  ) async {
    final novaSituacao = !serie.ativo;

    try {
      final alterada = await database.fichaTreinoDao.alterarSituacaoSerie(
        id: serie.id,
        ativo: novaSituacao,
      );

      if (!context.mounted) {
        return;
      }

      if (!alterada) {
        throw StateError('A série não foi encontrada.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              novaSituacao
                  ? 'Série ativada com sucesso.'
                  : 'Série inativada com sucesso.',
            ),
          ),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível alterar a situação da série.'),
          ),
        );
    }
  }

  Future<void> _reordenarSeries(
    BuildContext context,
    List<FichaExercicioSerie> series,
    int indiceAntigo,
    int indiceNovo,
  ) async {
    final seriesReordenadas = List<FichaExercicioSerie>.of(series);
    final serieMovida = seriesReordenadas.removeAt(indiceAntigo);
    seriesReordenadas.insert(indiceNovo, serieMovida);

    try {
      await database.fichaTreinoDao.reordenarSeries(
        fichaExercicioId: detalhe.fichaExercicio.id,
        serieIds: seriesReordenadas.map((serie) => serie.id).toList(),
      );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_mensagemDaExcecao(erro.message))),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível reordenar as séries.'),
          ),
        );
    }
  }

  Future<void> _confirmarRemocao(
    BuildContext context,
    FichaExercicioSerie serie,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover série'),
          content: Text(
            'Deseja remover a série ${serie.ordem} deste exercício?',
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
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !context.mounted) {
      return;
    }

    try {
      final removida = await database.fichaTreinoDao.removerSerie(id: serie.id);

      if (!context.mounted) {
        return;
      }

      if (!removida) {
        throw StateError('A série não foi encontrada.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Série removida.')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível remover a série.')),
        );
    }
  }

  String _mensagemDaExcecao(Object? mensagem) {
    final texto = mensagem?.toString().trim();

    if (texto == null || texto.isEmpty) {
      return 'Não foi possível concluir a operação.';
    }

    return texto;
  }

  @override
  Widget build(BuildContext context) {
    final rir = detalhe.fichaExercicio.rirPlanejado;
    final observacoes = detalhe.fichaExercicio.observacoes?.trim();

    return Scaffold(
      appBar: AppBar(title: Text(detalhe.exercicio.nome)),
      body: Column(
        children: [
          CabecalhoExercicio(
            rirPlanejado: rir,
            observacoes: observacoes,
            ativo: detalhe.fichaExercicio.ativo,
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<FichaExercicioSerie>>(
              stream: database.fichaTreinoDao.observarSeriesDoExercicio(
                detalhe.fichaExercicio.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar as séries planejadas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final series = snapshot.data!;

                if (series.isEmpty) {
                  return const EstadoVazioSeries();
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  buildDefaultDragHandles: false,
                  itemCount: series.length,
                  onReorderItem: (indiceAntigo, indiceNovo) {
                    _reordenarSeries(context, series, indiceAntigo, indiceNovo);
                  },
                  itemBuilder: (context, index) {
                    final serie = series[index];

                    return SerieCard(
                      key: ValueKey(serie.id),
                      serie: serie,
                      indice: index,
                      onTap: () async {
                        final alterada = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) {
                              return FichaExercicioSerieEditorPage(
                                database: database,
                                serie: serie,
                              );
                            },
                          ),
                        );

                        if (alterada != true || !context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Série atualizada com sucesso.'),
                            ),
                          );
                      },
                      onRemover: () {
                        _confirmarRemocao(context, serie);
                      },
                      onDuplicar: () {
                        _duplicarSerie(context, serie);
                      },
                      onAlterarSituacao: () {
                        _alterarSituacaoSerie(context, serie);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _adicionarSerie(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar série'),
      ),
    );
  }
}
