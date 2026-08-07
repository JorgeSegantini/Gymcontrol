import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/ficha_treino_dao.dart';
import 'ficha_exercicio_editor_page.dart';
import 'widgets/adicionar_exercicio_bottom_sheet.dart';
import 'widgets/informacao_serie.dart';

class FichaTreinoEditorPage extends StatefulWidget {
  const FichaTreinoEditorPage({
    required this.database,
    required this.fichaTreino,
    super.key,
  });

  final AppDatabase database;
  final FichaTreino fichaTreino;

  @override
  State<FichaTreinoEditorPage> createState() => _FichaTreinoEditorPageState();
}

class _FichaTreinoEditorPageState extends State<FichaTreinoEditorPage> {
  final Set<int> _exerciciosExpandidos = <int>{};

  AppDatabase get database => widget.database;

  FichaTreino get fichaTreino => widget.fichaTreino;

  Future<void> _abrirSeletorExercicio(BuildContext context) async {
    final exercicioSelecionado = await showModalBottomSheet<Exercicio>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) {
        return AdicionarExercicioBottomSheet(database: database);
      },
    );

    if (exercicioSelecionado == null || !context.mounted) {
      return;
    }

    try {
      await database.fichaTreinoDao.adicionarExercicio(
        fichaTreinoId: fichaTreino.id,
        exercicioId: exercicioSelecionado.id,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${exercicioSelecionado.nome} foi adicionado à ficha.',
            ),
          ),
        );
    } on StateError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_mensagemDaExcecao(erro.message))),
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
            content: Text('Não foi possível adicionar o exercício à ficha.'),
          ),
        );
    }
  }

  Future<void> _reordenarExercicios(
    BuildContext context,
    List<FichaExercicioDetalhe> exercicios,
    int indiceAntigo,
    int indiceNovo,
  ) async {
    final reordenados = List<FichaExercicioDetalhe>.of(exercicios);
    final movido = reordenados.removeAt(indiceAntigo);
    reordenados.insert(indiceNovo, movido);

    try {
      await database.fichaTreinoDao.reordenarExercicios(
        fichaTreinoId: fichaTreino.id,
        fichaExercicioIds: reordenados
            .map((detalhe) => detalhe.fichaExercicio.id)
            .toList(),
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
            content: Text('Não foi possível alterar a ordem dos exercícios.'),
          ),
        );
    }
  }

  Future<void> _abrirSeletorRir(
    BuildContext context,
    FichaExercicioDetalhe detalhe,
  ) async {
    final rirAtual = detalhe.fichaExercicio.rirPlanejado;

    final resultado = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        final alturaTela = MediaQuery.sizeOf(bottomSheetContext).height;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: alturaTela * 0.85),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'RIR planejado',
                  style: Theme.of(bottomSheetContext).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  detalhe.exercicio.nome,
                  style: Theme.of(bottomSheetContext).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.remove_circle_outline),
                      title: const Text('Não definir RIR'),
                      trailing: rirAtual == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop(-1);
                      },
                    ),
                    for (var rir = 0; rir <= 5; rir++)
                      ListTile(
                        leading: CircleAvatar(child: Text('$rir')),
                        title: Text('RIR $rir'),
                        subtitle: Text(_descricaoRir(rir)),
                        trailing: rirAtual == rir
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop(rir);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (resultado == null || !context.mounted) {
      return;
    }

    final novoRir = resultado == -1 ? null : resultado;

    try {
      final atualizado = await database.fichaTreinoDao.editarExercicioDaFicha(
        fichaExercicioId: detalhe.fichaExercicio.id,
        observacoes: detalhe.fichaExercicio.observacoes,
        rirPlanejado: novoRir,
        ativo: detalhe.fichaExercicio.ativo,
      );

      if (!context.mounted) {
        return;
      }

      if (!atualizado) {
        throw StateError('O exercício da ficha não foi encontrado.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              novoRir == null
                  ? 'RIR removido de ${detalhe.exercicio.nome}.'
                  : 'RIR $novoRir definido para ${detalhe.exercicio.nome}.',
            ),
          ),
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
          const SnackBar(content: Text('Não foi possível atualizar o RIR.')),
        );
    }
  }

  Future<void> _abrirEditorExercicio(
    BuildContext context,
    FichaExercicioDetalhe detalhe,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return FichaExercicioEditorPage(database: database, detalhe: detalhe);
        },
      ),
    );
  }

  Future<void> _removerExercicio(
    BuildContext context,
    FichaExercicioDetalhe detalhe,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover exercício'),
          content: Text(
            'Deseja remover "${detalhe.exercicio.nome}" desta ficha? '
            'As séries planejadas deste exercício também serão removidas.',
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

    if (confirmar != true || !context.mounted) {
      return;
    }

    try {
      final removido = await database.fichaTreinoDao.removerExercicio(
        fichaExercicioId: detalhe.fichaExercicio.id,
      );

      if (!context.mounted) {
        return;
      }

      if (!removido) {
        throw StateError('O exercício da ficha não foi encontrado.');
      }

      setState(() {
        _exerciciosExpandidos.remove(detalhe.fichaExercicio.id);
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${detalhe.exercicio.nome} foi removido da ficha.'),
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
            content: Text('Não foi possível remover o exercício da ficha.'),
          ),
        );
    }
  }

  void _alterarExpansao(int fichaExercicioId, bool expandido) {
    setState(() {
      if (expandido) {
        _exerciciosExpandidos.add(fichaExercicioId);
      } else {
        _exerciciosExpandidos.remove(fichaExercicioId);
      }
    });
  }

  static String _descricaoRir(int rir) {
    return switch (rir) {
      0 => 'Nenhuma repetição restante',
      1 => 'Aproximadamente 1 repetição restante',
      2 => 'Aproximadamente 2 repetições restantes',
      3 => 'Aproximadamente 3 repetições restantes',
      4 => 'Aproximadamente 4 repetições restantes',
      5 => 'Aproximadamente 5 repetições restantes',
      _ => '',
    };
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
    final descricao = fichaTreino.descricao?.trim();

    return Scaffold(
      appBar: AppBar(title: Text(fichaTreino.nome)),
      body: Column(
        children: [
          _CabecalhoFicha(fichaTreino: fichaTreino, descricao: descricao),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<FichaExercicioDetalhe>>(
              stream: database.fichaTreinoDao.observarExerciciosDaFicha(
                fichaTreino.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar os exercícios da ficha.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final exercicios = snapshot.data!;

                if (exercicios.isEmpty) {
                  return const _EstadoVazio();
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  buildDefaultDragHandles: true,
                  itemCount: exercicios.length,
                  onReorderItem: (indiceAntigo, indiceNovo) {
                    _reordenarExercicios(
                      context,
                      exercicios,
                      indiceAntigo,
                      indiceNovo,
                    );
                  },
                  itemBuilder: (context, index) {
                    final detalhe = exercicios[index];
                    final fichaExercicioId = detalhe.fichaExercicio.id;

                    return Padding(
                      key: ValueKey(fichaExercicioId),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ExercicioExpansivelCard(
                        database: database,
                        detalhe: detalhe,
                        inicialmenteExpandido: _exerciciosExpandidos.contains(
                          fichaExercicioId,
                        ),
                        onAlterarExpansao: (expandido) {
                          _alterarExpansao(fichaExercicioId, expandido);
                        },
                        onEditarRir: () {
                          _abrirSeletorRir(context, detalhe);
                        },
                        onAbrirEditor: () {
                          _abrirEditorExercicio(context, detalhe);
                        },
                        onRemover: () {
                          _removerExercicio(context, detalhe);
                        },
                      ),
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
          _abrirSeletorExercicio(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar exercício'),
      ),
    );
  }
}

enum _AcaoExercicioFicha { editar, remover }

class _ExercicioExpansivelCard extends StatelessWidget {
  const _ExercicioExpansivelCard({
    required this.database,
    required this.detalhe,
    required this.inicialmenteExpandido,
    required this.onAlterarExpansao,
    required this.onEditarRir,
    required this.onAbrirEditor,
    required this.onRemover,
  });

  final AppDatabase database;
  final FichaExercicioDetalhe detalhe;
  final bool inicialmenteExpandido;
  final ValueChanged<bool> onAlterarExpansao;
  final VoidCallback onEditarRir;
  final VoidCallback onAbrirEditor;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final rir = detalhe.fichaExercicio.rirPlanejado;
    final observacoes = detalhe.fichaExercicio.observacoes?.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<int>(detalhe.fichaExercicio.id),
        initiallyExpanded: inicialmenteExpandido,
        onExpansionChanged: onAlterarExpansao,
        leading: CircleAvatar(child: Text('${detalhe.fichaExercicio.ordem}')),
        title: Row(
          children: [
            Expanded(
              child: Text(
                detalhe.exercicio.nome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onEditarRir,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(rir == null ? 'RIR —' : 'RIR $rir'),
            ),
            PopupMenuButton<_AcaoExercicioFicha>(
              tooltip: 'Ações do exercício',
              onSelected: (acao) {
                switch (acao) {
                  case _AcaoExercicioFicha.editar:
                    onAbrirEditor();
                  case _AcaoExercicioFicha.remover:
                    onRemover();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: _AcaoExercicioFicha.editar,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar exercício e séries'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _AcaoExercicioFicha.remover,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline),
                      title: Text('Remover exercício'),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        subtitle: _criarSubtitulo(
          observacoes: observacoes,
          ativo: detalhe.fichaExercicio.ativo,
        ),
        children: [
          const Divider(height: 1),
          StreamBuilder<List<FichaExercicioSerie>>(
            stream: database.fichaTreinoDao.observarSeriesDoExercicio(
              detalhe.fichaExercicio.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Não foi possível carregar as séries deste exercício.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final series = snapshot.data!;

              return Column(
                children: [
                  if (series.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nenhuma série planejada para este exercício.',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < series.length;
                            index++
                          ) ...[
                            _SerieResumida(serie: series[index]),
                            if (index < series.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onAbrirEditor,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar exercício e séries'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _criarSubtitulo({required String? observacoes, required bool ativo}) {
    if (observacoes != null && observacoes.isNotEmpty) {
      return Text(observacoes, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    if (!ativo) {
      return const Text('Inativo');
    }

    return null;
  }
}

class _SerieResumida extends StatelessWidget {
  const _SerieResumida({required this.serie});

  final FichaExercicioSerie serie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(
              '${serie.ordem}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InformacaoSerie(
                  icone: Icons.category_outlined,
                  texto: _nomeTipoSerie(serie.tipoSerie),
                ),
                InformacaoSerie(
                  icone: Icons.repeat,
                  texto: _formatarRepeticoes(
                    serie.repeticoesMinimas,
                    serie.repeticoesMaximas,
                  ),
                ),
                InformacaoSerie(
                  icone: Icons.monitor_weight_outlined,
                  texto: _formatarCarga(serie.cargaPlanejadaGramas),
                ),
                InformacaoSerie(
                  icone: Icons.timer_outlined,
                  texto: _formatarDescanso(serie.descansoSegundos),
                ),
                if (!serie.ativo)
                  const Chip(
                    avatar: Icon(Icons.visibility_off_outlined, size: 16),
                    label: Text('Inativa'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _nomeTipoSerie(String tipoSerie) {
    return switch (tipoSerie) {
      'normal' => 'Normal',
      'aquecimento' => 'Aquecimento',
      'dropSet' => 'Drop set',
      'restPause' => 'Rest-pause',
      'biSet' => 'Bi-set',
      'triSet' => 'Tri-set',
      'cluster' => 'Cluster',
      'isometrica' => 'Isométrica',
      _ => tipoSerie,
    };
  }

  static String _formatarRepeticoes(
    int? repeticoesMinimas,
    int? repeticoesMaximas,
  ) {
    if (repeticoesMinimas == null && repeticoesMaximas == null) {
      return 'Repetições não definidas';
    }

    if (repeticoesMinimas != null &&
        repeticoesMaximas != null &&
        repeticoesMinimas != repeticoesMaximas) {
      return '$repeticoesMinimas–$repeticoesMaximas rep';
    }

    final repeticoes = repeticoesMinimas ?? repeticoesMaximas;

    return '$repeticoes rep';
  }

  static String _formatarCarga(int? cargaGramas) {
    if (cargaGramas == null) {
      return 'Carga não definida';
    }

    final cargaQuilos = cargaGramas / 1000;

    if (cargaQuilos == cargaQuilos.roundToDouble()) {
      return '${cargaQuilos.toInt()} kg';
    }

    return '${cargaQuilos.toStringAsFixed(1)} kg';
  }

  static String _formatarDescanso(int descansoSegundos) {
    if (descansoSegundos == 0) {
      return 'Sem descanso definido';
    }

    final minutos = descansoSegundos ~/ 60;
    final segundos = descansoSegundos % 60;

    if (minutos == 0) {
      return '$segundos s';
    }

    if (segundos == 0) {
      return '$minutos min';
    }

    return '$minutos min $segundos s';
  }
}

class _CabecalhoFicha extends StatelessWidget {
  const _CabecalhoFicha({required this.fichaTreino, required this.descricao});

  final FichaTreino fichaTreino;
  final String? descricao;

  @override
  Widget build(BuildContext context) {
    final corFicha = Color(fichaTreino.corArgb);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: corFicha,
            foregroundColor: _corDoConteudo(corFicha),
            child: const Icon(Icons.assignment),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fichaTreino.nome,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  descricao == null || descricao!.isEmpty
                      ? 'Sem descrição'
                      : descricao!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!fichaTreino.ativo) ...[
                  const SizedBox(height: 8),
                  const Chip(
                    avatar: Icon(Icons.block, size: 18),
                    label: Text('Ficha inativa'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _corDoConteudo(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum exercício adicionado',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use o botão “Adicionar exercício” para começar a montar '
              'esta ficha de treino.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
