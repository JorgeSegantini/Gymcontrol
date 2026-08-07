import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class PlanoItemFormData {
  const PlanoItemFormData({
    required this.tipo,
    required this.nome,
    required this.codigo,
    required this.descricao,
    required this.fichaTreinoId,
  });

  final TipoPlanoTreinoItem tipo;
  final String nome;
  final String? codigo;
  final String? descricao;
  final int? fichaTreinoId;
}

class PlanoItemDialog extends StatefulWidget {
  const PlanoItemDialog({required this.database, this.item, super.key});

  final AppDatabase database;
  final PlanoTreinoItem? item;

  @override
  State<PlanoItemDialog> createState() => _PlanoItemDialogState();
}

class _PlanoItemDialogState extends State<PlanoItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  late TipoPlanoTreinoItem _tipo;
  int? _fichaTreinoId;
  String? _fichaTreinoNome;
  String? _fichaTreinoDescricao;

  bool get _editando => widget.item != null;
  bool get _ehTreino => _tipo == TipoPlanoTreinoItem.treino;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item == null) {
      _tipo = TipoPlanoTreinoItem.treino;
      return;
    }

    _tipo = TipoPlanoTreinoItem.values.firstWhere(
      (tipo) => tipo.name == item.tipo,
      orElse: () => TipoPlanoTreinoItem.personalizado,
    );
    _fichaTreinoId = item.fichaTreinoId;
    _codigoController.text = item.codigo ?? '';
    _nomeController.text = item.nome;
    _descricaoController.text = item.descricao ?? '';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _alterarTipo(TipoPlanoTreinoItem tipo) {
    setState(() {
      _tipo = tipo;

      if (tipo != TipoPlanoTreinoItem.treino) {
        _fichaTreinoId = null;
        _fichaTreinoNome = null;
        _fichaTreinoDescricao = null;

        if (_nomeController.text.trim().isEmpty ||
            _nomeController.text.trim() == 'Treino') {
          _nomeController.text = _nomePadrao(tipo);
        }
      } else {
        _nomeController.clear();
      }
    });
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nome = _ehTreino
        ? (_fichaTreinoNome ?? widget.item?.nome ?? '').trim()
        : _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar o nome da etapa.'),
          ),
        );
      return;
    }

    Navigator.of(context).pop(
      PlanoItemFormData(
        tipo: _tipo,
        nome: nome,
        codigo: _textoOpcional(_codigoController.text),
        descricao: _ehTreino
            ? _textoOpcional(_fichaTreinoDescricao ?? '')
            : _textoOpcional(_descricaoController.text),
        fichaTreinoId: _fichaTreinoId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text(_editando ? 'Editar etapa' : 'Adicionar etapa'),
      content: SizedBox(
        width: largura > 520 ? 460 : largura,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'O tipo define o ícone usado para identificar a etapa '
                  'no plano e na Home.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TipoPlanoTreinoItem>(
                  initialValue: _tipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo da etapa',
                    prefixIcon: Icon(_iconeTipo(_tipo)),
                  ),
                  items: [
                    for (final tipo in TipoPlanoTreinoItem.values)
                      DropdownMenuItem(
                        value: tipo,
                        child: Row(
                          children: [
                            Icon(_iconeTipo(tipo), size: 20),
                            const SizedBox(width: 10),
                            Text(_nomeTipo(tipo)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (tipo) {
                    if (tipo != null) {
                      _alterarTipo(tipo);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_ehTreino) ...[
                  StreamBuilder<List<FichaTreino>>(
                    stream: widget.database.fichaTreinoDao.observarAtivas(),
                    builder: (context, snapshot) {
                      final fichas = snapshot.data ?? const <FichaTreino>[];

                      FichaTreino? fichaSelecionada;
                      for (final ficha in fichas) {
                        if (ficha.id == _fichaTreinoId) {
                          fichaSelecionada = ficha;
                          break;
                        }
                      }

                      if (fichaSelecionada != null) {
                        _fichaTreinoNome = fichaSelecionada.nome;
                        _fichaTreinoDescricao = fichaSelecionada.descricao;
                      }

                      return DropdownButtonFormField<int>(
                        initialValue: _fichaTreinoId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Ficha de treino',
                          prefixIcon: Icon(Icons.assignment_outlined),
                          helperText:
                              'Nome e descrição da ficha serão usados '
                              'automaticamente nesta etapa.',
                        ),
                        items: [
                          for (final ficha in fichas)
                            DropdownMenuItem(
                              value: ficha.id,
                              child: Text(
                                ficha.nome,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: snapshot.hasData && fichas.isNotEmpty
                            ? (valor) {
                                setState(() {
                                  _fichaTreinoId = valor;

                                  if (valor == null) {
                                    _fichaTreinoNome = null;
                                    _fichaTreinoDescricao = null;
                                    return;
                                  }

                                  final ficha = fichas.firstWhere(
                                    (item) => item.id == valor,
                                  );
                                  _fichaTreinoNome = ficha.nome;
                                  _fichaTreinoDescricao = ficha.descricao;
                                });
                              }
                            : null,
                        validator: (valor) {
                          if (_ehTreino && valor == null) {
                            return 'Selecione uma ficha de treino.';
                          }

                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _codigoController,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Identificador opcional',
                    hintText: 'A, B, C...',
                    prefixIcon: Icon(Icons.tag_outlined),
                    helperText:
                        'Aparece no card da etapa para facilitar a '
                        'identificação no plano.',
                  ),
                ),
                if (!_ehTreino) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeController,
                    maxLength: 120,
                    decoration: InputDecoration(
                      labelText: 'Nome da etapa',
                      hintText: _nomePadrao(_tipo),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (valor) {
                      if (!_ehTreino &&
                          (valor == null || valor.trim().isEmpty)) {
                        return 'Informe o nome da etapa.';
                      }

                      return null;
                    },
                  ),
                ],
                if (!_ehTreino) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descricaoController,
                    maxLength: 500,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição opcional',
                      hintText: 'Ex.: caminhada leve, mobilidade de quadril...',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                      helperText:
                          'Aparece como informação complementar da etapa.',
                    ),
                  ),
                ] else if (_fichaTreinoDescricao?.trim().isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fichaTreinoDescricao!.trim(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _PreviaEtapa(
                  tipo: _tipo,
                  codigo: _textoOpcional(_codigoController.text),
                  nome: _ehTreino
                      ? (_fichaTreinoNome ?? 'Selecione uma ficha')
                      : (_nomeController.text.trim().isEmpty
                            ? _nomePadrao(_tipo)
                            : _nomeController.text.trim()),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: Text(_editando ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }

  static String _nomeTipo(TipoPlanoTreinoItem tipo) {
    return switch (tipo) {
      TipoPlanoTreinoItem.treino => 'Treino',
      TipoPlanoTreinoItem.descanso => 'Descanso',
      TipoPlanoTreinoItem.cardio => 'Cardio',
      TipoPlanoTreinoItem.mobilidade => 'Mobilidade',
      TipoPlanoTreinoItem.personalizado => 'Personalizado',
    };
  }

  static IconData _iconeTipo(TipoPlanoTreinoItem tipo) {
    return switch (tipo) {
      TipoPlanoTreinoItem.treino => Icons.fitness_center_outlined,
      TipoPlanoTreinoItem.descanso => Icons.bedtime_outlined,
      TipoPlanoTreinoItem.cardio => Icons.directions_run_outlined,
      TipoPlanoTreinoItem.mobilidade => Icons.self_improvement_outlined,
      TipoPlanoTreinoItem.personalizado => Icons.tune_outlined,
    };
  }

  static String _nomePadrao(TipoPlanoTreinoItem tipo) {
    return switch (tipo) {
      TipoPlanoTreinoItem.treino => 'Treino',
      TipoPlanoTreinoItem.descanso => 'Descanso',
      TipoPlanoTreinoItem.cardio => 'Cardio',
      TipoPlanoTreinoItem.mobilidade => 'Mobilidade',
      TipoPlanoTreinoItem.personalizado => 'Etapa personalizada',
    };
  }

  static String? _textoOpcional(String texto) {
    final valor = texto.trim();
    return valor.isEmpty ? null : valor;
  }
}

class _PreviaEtapa extends StatelessWidget {
  const _PreviaEtapa({
    required this.tipo,
    required this.codigo,
    required this.nome,
  });

  final TipoPlanoTreinoItem tipo;
  final String? codigo;
  final String nome;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: codigo == null
                ? Icon(
                    _PlanoItemDialogState._iconeTipo(tipo),
                    color: colorScheme.onPrimaryContainer,
                  )
                : Text(
                    codigo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prévia no plano',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
