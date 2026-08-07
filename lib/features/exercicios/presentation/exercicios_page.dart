import 'package:flutter/material.dart';

import '../../../core/biblioteca/services/biblioteca_pesquisa_service.dart';
import '../../../core/database/app_database.dart';
import 'exercicio_detalhes_page.dart';
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

  Future<void> _abrirDetalhes(BuildContext context, Exercicio exercicio) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercicioDetalhesPage(
          database: widget.database,
          exercicioId: exercicio.id,
        ),
      ),
    );
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

  String _nomeEquipamento(String equipamentoSalvo) {
    final equipamento = widget.database.exercicioDao.converterEquipamento(
      equipamentoSalvo,
    );

    return switch (equipamento) {
      EquipamentoExercicio.barra => 'Barra',
      EquipamentoExercicio.halteres => 'Halteres',
      EquipamentoExercicio.maquina => 'Máquina',
      EquipamentoExercicio.polia => 'Polia',
      EquipamentoExercicio.smith => 'Smith',
      EquipamentoExercicio.pesoCorporal => 'Peso corporal',
      EquipamentoExercicio.kettlebell => 'Kettlebell',
      EquipamentoExercicio.elastico => 'Elástico',
      EquipamentoExercicio.bolaSuica => 'Bola suíça',
      EquipamentoExercicio.trx => 'TRX',
      EquipamentoExercicio.banco => 'Banco',
      EquipamentoExercicio.outro => 'Outro',
    };
  }

  IconData _iconeTipo(String tipoSalvo) {
    final tipo = widget.database.exercicioDao.converterTipo(tipoSalvo);

    return switch (tipo) {
      TipoExercicio.musculacao => Icons.fitness_center_outlined,
      TipoExercicio.cardio => Icons.directions_run_outlined,
      TipoExercicio.mobilidade => Icons.self_improvement_outlined,
      TipoExercicio.alongamento => Icons.accessibility_new_outlined,
    };
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      controller: _pesquisaController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar exercícios',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _pesquisaController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar pesquisa',
                                onPressed: _pesquisaController.clear,
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            key: ValueKey(_grupoMuscularId),
                            initialValue: _grupoMuscularId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Grupo',
                              border: OutlineInputBorder(),
                              isDense: true,
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
                                    overflow: TextOverflow.ellipsis,
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
                        const SizedBox(width: 10),
                        FilterChip(
                          selected: _incluirInativos,
                          label: const Text('Inativos'),
                          avatar: Icon(
                            _incluirInativos
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onSelected: (selecionado) {
                            setState(() {
                              _incluirInativos = selecionado;
                            });
                          },
                        ),
                      ],
                    ),
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

                            final colorScheme = Theme.of(context).colorScheme;

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  _abrirDetalhes(context, exercicio);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _iconeTipo(exercicio.tipo),
                                          size: 22,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercicio.nome,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              grupo,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                _ExercicioInfoChip(
                                                  texto: _nomeTipo(
                                                    exercicio.tipo,
                                                  ),
                                                ),
                                                _ExercicioInfoChip(
                                                  texto: _nomeEquipamento(
                                                    exercicio.equipamento,
                                                  ),
                                                ),
                                                if (!exercicio.ativo)
                                                  const _ExercicioInfoChip(
                                                    texto: 'Inativo',
                                                    destaque: true,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Opções',
                                        onPressed: () {
                                          _abrirOpcoes(context, exercicio);
                                        },
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                    ],
                                  ),
                                ),
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

class _ExercicioInfoChip extends StatelessWidget {
  const _ExercicioInfoChip({required this.texto, this.destaque = false});

  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: destaque
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: destaque
              ? colorScheme.onErrorContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
