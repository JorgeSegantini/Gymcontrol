import 'package:flutter/material.dart';

import '../../../core/biblioteca/services/biblioteca_pesquisa_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/codigo_formatador.dart';
import 'exercicio_form_dialog.dart';
import 'exercicio_opcoes_dialog.dart';

class ExerciciosPage extends StatefulWidget {
  const ExerciciosPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  final TextEditingController _pesquisaController = TextEditingController();
  final BibliotecaPesquisaService _pesquisaService =
      BibliotecaPesquisaService();

  int? _grupoMuscularId;
  bool _incluirInativos = false;

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

  Future<void> _abrirFormularioCadastro(BuildContext context) async {
    final exercicioCadastrado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ExercicioFormDialog(database: widget.database);
      },
    );

    if (exercicioCadastrado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício cadastrado com sucesso.')),
      );
    }
  }

  Future<void> _abrirFormularioEdicao(
    BuildContext context,
    Exercicio exercicio,
  ) async {
    final exercicioEditado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ExercicioFormDialog(
          database: widget.database,
          exercicio: exercicio,
        );
      },
    );

    if (exercicioEditado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício editado com sucesso.')),
      );
    }
  }

  Future<void> _alterarSituacao(
    BuildContext context,
    Exercicio exercicio,
  ) async {
    try {
      final alterado = await widget.database.exercicioDao.alterarSituacao(
        id: exercicio.id,
        ativo: !exercicio.ativo,
      );

      if (!context.mounted) {
        return;
      }

      if (!alterado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O exercício não foi encontrado.')),
        );
        return;
      }

      final mensagem = exercicio.ativo
          ? 'Exercício inativado com sucesso.'
          : 'Exercício ativado com sucesso.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível alterar a situação do exercício.'),
        ),
      );
    }
  }

  Future<void> _abrirOpcoes(BuildContext context, Exercicio exercicio) async {
    final acao = await showDialog<AcaoExercicio>(
      context: context,
      builder: (_) {
        return ExercicioOpcoesDialog(exercicio: exercicio);
      },
    );

    if (acao == null || !context.mounted) {
      return;
    }

    switch (acao) {
      case AcaoExercicio.editar:
        await _abrirFormularioEdicao(context, exercicio);
        break;

      case AcaoExercicio.alterarSituacao:
        await _alterarSituacao(context, exercicio);
        break;
    }
  }

  String _nomeGrupoMuscular(int grupoMuscularId, List<GrupoMuscular> grupos) {
    for (final grupo in grupos) {
      if (grupo.id == grupoMuscularId) {
        return grupo.nome;
      }
    }

    return 'Grupo não encontrado';
  }

  String _nomeTipo(String tipoSalvo) {
    final tipo = widget.database.exercicioDao.converterTipo(tipoSalvo);

    switch (tipo) {
      case TipoExercicio.musculacao:
        return 'Musculação';
      case TipoExercicio.cardio:
        return 'Cardio';
      case TipoExercicio.mobilidade:
        return 'Mobilidade';
      case TipoExercicio.alongamento:
        return 'Alongamento';
    }
  }

  Future<List<Exercicio>> _pesquisar(
    List<Exercicio> exercicios,
    List<GrupoMuscular> grupos,
  ) {
    return _pesquisaService.pesquisar(
      exercicios: exercicios,
      grupos: grupos,
      termo: _pesquisaController.text,
      grupoMuscularId: _grupoMuscularId,
      incluirInativos: _incluirInativos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      body: StreamBuilder<List<GrupoMuscular>>(
        stream: widget.database.grupoMuscularDao.observarTodos(),
        builder: (context, gruposSnapshot) {
          if (gruposSnapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os grupos musculares.'),
            );
          }

          if (!gruposSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final grupos = gruposSnapshot.data!;

          return StreamBuilder<List<Exercicio>>(
            stream: widget.database.exercicioDao.observarTodos(),
            builder: (context, exerciciosSnapshot) {
              if (exerciciosSnapshot.hasError) {
                return const Center(
                  child: Text('Não foi possível carregar os exercícios.'),
                );
              }

              if (!exerciciosSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _pesquisaController,
                      decoration: InputDecoration(
                        labelText: 'Pesquisar',
                        hintText:
                            'Nome, alias, grupo, equipamento, tag ou código',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<int?>(
                      key: ValueKey(_grupoMuscularId),
                      initialValue: _grupoMuscularId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Grupo muscular',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todos os grupos'),
                        ),
                        ...grupos.map(
                          (grupo) => DropdownMenuItem<int?>(
                            value: grupo.id,
                            child: Text(
                              grupo.ativo
                                  ? grupo.nome
                                  : '${grupo.nome} — Inativo',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (valor) {
                        setState(() {
                          _grupoMuscularId = valor;
                        });
                      },
                    ),
                  ),
                  CheckboxListTile(
                    value: _incluirInativos,
                    title: const Text('Mostrar exercícios inativos'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (valor) {
                      setState(() {
                        _incluirInativos = valor ?? false;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<Exercicio>>(
                      future: _pesquisar(exerciciosSnapshot.data!, grupos),
                      builder: (context, pesquisaSnapshot) {
                        if (pesquisaSnapshot.hasError) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Não foi possível pesquisar os exercícios.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        if (!pesquisaSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final exercicios = pesquisaSnapshot.data!;

                        if (exercicios.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhum exercício encontrado.',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(16),
                          itemCount: exercicios.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final exercicio = exercicios[index];
                            final grupo = _nomeGrupoMuscular(
                              exercicio.grupoMuscularId,
                              grupos,
                            );

                            return Card(
                              child: ListTile(
                                isThreeLine: true,
                                leading: CircleAvatar(
                                  child: Text('${exercicio.ordem}'),
                                ),
                                title: Text(exercicio.nome),
                                subtitle: Text(
                                  '${CodigoFormatador.exercicio(exercicio.id)}\n'
                                  '$grupo • ${_nomeTipo(exercicio.tipo)}'
                                  '${exercicio.ativo ? '' : ' • Inativo'}',
                                ),
                                trailing: const Icon(Icons.more_vert),
                                onTap: () {
                                  _abrirOpcoes(context, exercicio);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _abrirFormularioCadastro(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo exercício'),
      ),
    );
  }
}
