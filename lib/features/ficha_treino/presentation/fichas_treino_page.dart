import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../treino/presentation/treino_execucao_page.dart';
import 'ficha_treino_editor_page.dart';
import 'ficha_treino_form_dialog.dart';
import 'ficha_treino_opcoes_dialog.dart';

class FichasTreinoPage extends StatefulWidget {
  const FichasTreinoPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<FichasTreinoPage> createState() => _FichasTreinoPageState();
}

class _FichasTreinoPageState extends State<FichasTreinoPage> {
  final TextEditingController _pesquisaController = TextEditingController();

  bool _incluirInativas = false;
  int? _fichaIniciandoId;

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(_atualizarPesquisa);
  }

  @override
  void dispose() {
    _pesquisaController
      ..removeListener(_atualizarPesquisa)
      ..dispose();

    super.dispose();
  }

  void _atualizarPesquisa() {
    setState(() {});
  }

  List<FichaTreino> _aplicarFiltros(List<FichaTreino> fichas) {
    final pesquisa = _pesquisaController.text.trim().toLowerCase();

    return fichas.where((ficha) {
      if (!_incluirInativas && !ficha.ativo) {
        return false;
      }

      if (pesquisa.isEmpty) {
        return true;
      }

      final nome = ficha.nome.toLowerCase();
      final descricao = ficha.descricao?.toLowerCase() ?? '';

      return nome.contains(pesquisa) || descricao.contains(pesquisa);
    }).toList();
  }

  Future<void> _reordenarFichas(
    BuildContext context,
    List<FichaTreino> fichas,
    int indiceAntigo,
    int indiceNovo,
  ) async {
    final reordenadas = List<FichaTreino>.of(fichas);
    final movida = reordenadas.removeAt(indiceAntigo);
    reordenadas.insert(indiceNovo, movida);

    try {
      await widget.database.fichaTreinoDao.reordenarFichas(
        fichaIds: reordenadas.map((ficha) => ficha.id).toList(),
      );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(context, _mensagemDaExcecao(erro.message));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(context, 'Não foi possível alterar a ordem das fichas.');
    }
  }

  Future<void> _abrirFormularioCadastro(BuildContext context) async {
    final fichaCadastrada = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return FichaTreinoFormDialog(database: widget.database);
      },
    );

    if (fichaCadastrada == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Ficha de treino cadastrada com sucesso.'),
          ),
        );
    }
  }

  Future<void> _abrirFormularioEdicao(
    BuildContext context,
    FichaTreino fichaTreino,
  ) async {
    final fichaEditada = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return FichaTreinoFormDialog(
          database: widget.database,
          fichaTreino: fichaTreino,
        );
      },
    );

    if (fichaEditada == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Ficha de treino editada com sucesso.')),
        );
    }
  }

  Future<void> _abrirEditor(
    BuildContext context,
    FichaTreino fichaTreino,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return FichaTreinoEditorPage(
            database: widget.database,
            fichaTreino: fichaTreino,
          );
        },
      ),
    );
  }

  Future<void> _iniciarTreino(
    BuildContext context,
    FichaTreino fichaTreino,
  ) async {
    if (!fichaTreino.ativo || _fichaIniciandoId != null) {
      return;
    }

    setState(() {
      _fichaIniciandoId = fichaTreino.id;
    });

    try {
      final treinoRealizadoId = await widget.database.treinoRealizadoDao
          .iniciarTreinoDaFicha(fichaTreinoId: fichaTreino.id);

      if (!context.mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) {
            return TreinoExecucaoPage(
              database: widget.database,
              treinoRealizadoId: treinoRealizadoId,
            );
          },
        ),
      );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(context, _mensagemDaExcecao(erro.message));
    } on StateError catch (erro) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(context, _mensagemDaExcecao(erro.message));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(context, 'Não foi possível iniciar o treino.');
    } finally {
      if (mounted) {
        setState(() {
          _fichaIniciandoId = null;
        });
      }
    }
  }

  Future<void> _alterarSituacao(
    BuildContext context,
    FichaTreino fichaTreino,
  ) async {
    try {
      final alterado = await widget.database.fichaTreinoDao.alterarSituacao(
        id: fichaTreino.id,
        ativo: !fichaTreino.ativo,
      );

      if (!context.mounted) {
        return;
      }

      if (!alterado) {
        _mostrarMensagem(context, 'A ficha de treino não foi encontrada.');
        return;
      }

      _mostrarMensagem(
        context,
        fichaTreino.ativo
            ? 'Ficha de treino inativada com sucesso.'
            : 'Ficha de treino ativada com sucesso.',
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _mostrarMensagem(
        context,
        'Não foi possível alterar a situação da ficha de treino.',
      );
    }
  }

  Future<void> _abrirOpcoes(
    BuildContext context,
    FichaTreino fichaTreino,
  ) async {
    final acao = await showDialog<AcaoFichaTreino>(
      context: context,
      builder: (_) {
        return FichaTreinoOpcoesDialog(fichaTreino: fichaTreino);
      },
    );

    if (acao == null || !context.mounted) {
      return;
    }

    switch (acao) {
      case AcaoFichaTreino.editar:
        await _abrirFormularioEdicao(context, fichaTreino);
        break;

      case AcaoFichaTreino.alterarSituacao:
        await _alterarSituacao(context, fichaTreino);
        break;
    }
  }

  void _mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _descricaoFicha(FichaTreino fichaTreino) {
    final descricao = fichaTreino.descricao?.trim();

    if (descricao == null || descricao.isEmpty) {
      return fichaTreino.ativo ? 'Sem descrição' : 'Sem descrição • Inativa';
    }

    return fichaTreino.ativo ? descricao : '$descricao • Inativa';
  }

  String _mensagemDaExcecao(Object? mensagem) {
    final texto = mensagem?.toString().trim();

    if (texto == null || texto.isEmpty) {
      return 'Não foi possível concluir a operação.';
    }

    return texto;
  }

  Color _corDoConteudo(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fichas de treino')),
      body: StreamBuilder<List<FichaTreino>>(
        stream: widget.database.fichaTreinoDao.observarTodas(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Não foi possível carregar as fichas de treino.',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final fichas = _aplicarFiltros(snapshot.data!);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _pesquisaController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                    hintText: 'Nome ou descrição da ficha',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _pesquisaController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar pesquisa',
                            onPressed: _pesquisaController.clear,
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              CheckboxListTile(
                value: _incluirInativas,
                title: const Text('Mostrar fichas inativas'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onChanged: (valor) {
                  setState(() {
                    _incluirInativas = valor ?? false;
                  });
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: fichas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma ficha de treino encontrada.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _pesquisaController.text.trim().isEmpty &&
                          !_incluirInativas
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        buildDefaultDragHandles: true,
                        itemCount: fichas.length,
                        onReorderItem: (indiceAntigo, indiceNovo) {
                          _reordenarFichas(
                            context,
                            fichas,
                            indiceAntigo,
                            indiceNovo,
                          );
                        },
                        itemBuilder: (context, index) {
                          final fichaTreino = fichas[index];

                          return Padding(
                            key: ValueKey(fichaTreino.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FichaTreinoCard(
                              fichaTreino: fichaTreino,
                              iniciando: _fichaIniciandoId == fichaTreino.id,
                              corDoConteudo: _corDoConteudo,
                              descricao: _descricaoFicha(fichaTreino),
                              onIniciar: () {
                                _iniciarTreino(context, fichaTreino);
                              },
                              onMontar: () {
                                _abrirEditor(context, fichaTreino);
                              },
                              onMaisOpcoes: () {
                                _abrirOpcoes(context, fichaTreino);
                              },
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        itemCount: fichas.length,
                        separatorBuilder: (_, _) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final fichaTreino = fichas[index];

                          return _FichaTreinoCard(
                            fichaTreino: fichaTreino,
                            iniciando: _fichaIniciandoId == fichaTreino.id,
                            corDoConteudo: _corDoConteudo,
                            descricao: _descricaoFicha(fichaTreino),
                            onIniciar: () {
                              _iniciarTreino(context, fichaTreino);
                            },
                            onMontar: () {
                              _abrirEditor(context, fichaTreino);
                            },
                            onMaisOpcoes: () {
                              _abrirOpcoes(context, fichaTreino);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _abrirFormularioCadastro(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova ficha'),
      ),
    );
  }
}

class _FichaTreinoCard extends StatelessWidget {
  const _FichaTreinoCard({
    required this.fichaTreino,
    required this.iniciando,
    required this.corDoConteudo,
    required this.descricao,
    required this.onIniciar,
    required this.onMontar,
    required this.onMaisOpcoes,
  });

  final FichaTreino fichaTreino;
  final bool iniciando;
  final Color Function(Color backgroundColor) corDoConteudo;
  final String descricao;
  final VoidCallback onIniciar;
  final VoidCallback onMontar;
  final VoidCallback onMaisOpcoes;

  @override
  Widget build(BuildContext context) {
    final corFicha = Color(fichaTreino.corArgb);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: corFicha,
                  foregroundColor: corDoConteudo(corFicha),
                  child: Text('${fichaTreino.ordem}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fichaTreino.nome,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descricao,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Mais opções',
                  onPressed: onMaisOpcoes,
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: fichaTreino.ativo && !iniciando
                        ? onIniciar
                        : null,
                    icon: iniciando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(iniciando ? 'Iniciando...' : 'Iniciar treino'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onMontar,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Montar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
