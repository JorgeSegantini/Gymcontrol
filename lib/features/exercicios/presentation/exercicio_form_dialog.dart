import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/codigo_formatador.dart';

class ExercicioFormDialog extends StatefulWidget {
  const ExercicioFormDialog({
    required this.database,
    this.exercicio,
    super.key,
  });

  final AppDatabase database;
  final Exercicio? exercicio;

  bool get editando => exercicio != null;

  @override
  State<ExercicioFormDialog> createState() => _ExercicioFormDialogState();
}

class _ExercicioFormDialogState extends State<ExercicioFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _ordemController;
  late final TextEditingController _instrucoesController;

  int? _grupoMuscularId;
  late TipoExercicio _tipoSelecionado;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    final exercicio = widget.exercicio;

    _nomeController = TextEditingController(text: exercicio?.nome ?? '');

    _ordemController = TextEditingController(text: '${exercicio?.ordem ?? 0}');

    _instrucoesController = TextEditingController(
      text: exercicio?.instrucoes ?? '',
    );

    _grupoMuscularId = exercicio?.grupoMuscularId;

    _tipoSelecionado = exercicio == null
        ? TipoExercicio.musculacao
        : widget.database.exercicioDao.converterTipo(exercicio.tipo);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ordemController.dispose();
    _instrucoesController.dispose();
    super.dispose();
  }

  String _nomeTipo(TipoExercicio tipo) {
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

  Future<void> _salvar() async {
    if (_salvando) {
      return;
    }

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido || _grupoMuscularId == null) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final nome = _nomeController.text.trim();
      final ordem = int.parse(_ordemController.text.trim());
      final instrucoes = _instrucoesController.text.trim();

      if (widget.editando) {
        await widget.database.exercicioDao.editar(
          id: widget.exercicio!.id,
          grupoMuscularId: _grupoMuscularId!,
          nome: nome,
          tipo: _tipoSelecionado,
          instrucoes: instrucoes,
          ordem: ordem,
        );
      } else {
        await widget.database.exercicioDao.cadastrar(
          grupoMuscularId: _grupoMuscularId!,
          nome: nome,
          tipo: _tipoSelecionado,
          instrucoes: instrucoes,
          ordem: ordem,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _salvando = false;
      });

      final textoErro = erro.toString().toLowerCase();

      final nomeDuplicado =
          textoErro.contains('unique') ||
          textoErro.contains('exercicios.grupo_muscular_id') ||
          textoErro.contains('exercicios.nome');

      final mensagem = nomeDuplicado
          ? 'Já existe um exercício com esse nome neste grupo muscular.'
          : widget.editando
          ? 'Não foi possível editar o exercício.'
          : 'Não foi possível cadastrar o exercício.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editando ? 'Editar exercício' : 'Novo exercício'),
      content: SizedBox(
        width: 500,
        child: StreamBuilder<List<GrupoMuscular>>(
          stream: widget.database.grupoMuscularDao.observarTodos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'Não foi possível carregar os grupos musculares.',
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final grupos = snapshot.data!;

            final gruposDisponiveis = grupos.where((grupo) {
              return grupo.ativo || grupo.id == _grupoMuscularId;
            }).toList();

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        widget.editando
                            ? CodigoFormatador.exercicio(widget.exercicio!.id)
                            : 'Gerado automaticamente ao salvar',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _grupoMuscularId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Grupo muscular',
                        border: OutlineInputBorder(),
                      ),
                      items: gruposDisponiveis.map((grupo) {
                        return DropdownMenuItem<int>(
                          value: grupo.id,
                          child: Text(
                            grupo.ativo
                                ? grupo.nome
                                : '${grupo.nome} — Inativo',
                          ),
                        );
                      }).toList(),
                      onChanged: _salvando
                          ? null
                          : (valor) {
                              setState(() {
                                _grupoMuscularId = valor;
                              });
                            },
                      validator: (valor) {
                        if (valor == null) {
                          return 'Selecione o grupo muscular.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      autofocus: true,
                      enabled: !_salvando,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Ex.: Supino reto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        final nome = valor?.trim() ?? '';

                        if (nome.isEmpty) {
                          return 'Informe o nome do exercício.';
                        }

                        if (nome.length > 150) {
                          return 'O nome deve ter no máximo 150 caracteres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TipoExercicio>(
                      initialValue: _tipoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: TipoExercicio.values.map((tipo) {
                        return DropdownMenuItem<TipoExercicio>(
                          value: tipo,
                          child: Text(_nomeTipo(tipo)),
                        );
                      }).toList(),
                      onChanged: _salvando
                          ? null
                          : (valor) {
                              if (valor == null) {
                                return;
                              }

                              setState(() {
                                _tipoSelecionado = valor;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ordemController,
                      enabled: !_salvando,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Ordem',
                        helperText:
                            'Define a posição do exercício dentro da lista.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        final ordem = int.tryParse(valor?.trim() ?? '');

                        if (ordem == null) {
                          return 'Informe um número inteiro válido.';
                        }

                        if (ordem < 0) {
                          return 'A ordem não pode ser negativa.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instrucoesController,
                      enabled: !_salvando,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Instruções',
                        hintText:
                            'Descreva a execução, postura e cuidados do exercício.',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        final instrucoes = valor?.trim() ?? '';

                        if (instrucoes.length > 2000) {
                          return 'As instruções devem ter no máximo 2000 caracteres.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.editando ? 'Salvar alterações' : 'Salvar'),
        ),
      ],
    );
  }
}
