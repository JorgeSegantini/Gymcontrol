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

  bool get _editando => widget.item != null;

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
      }

      if (_nomeController.text.trim().isEmpty) {
        _nomeController.text = _nomePadrao(tipo);
      }
    });
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      PlanoItemFormData(
        tipo: _tipo,
        nome: _nomeController.text.trim(),
        codigo: _textoOpcional(_codigoController.text),
        descricao: _textoOpcional(_descricaoController.text),
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
              children: [
                DropdownButtonFormField<TipoPlanoTreinoItem>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final tipo in TipoPlanoTreinoItem.values)
                      DropdownMenuItem(
                        value: tipo,
                        child: Text(_nomeTipo(tipo)),
                      ),
                  ],
                  onChanged: (tipo) {
                    if (tipo != null) {
                      _alterarTipo(tipo);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_tipo == TipoPlanoTreinoItem.treino) ...[
                  StreamBuilder<List<FichaTreino>>(
                    stream: widget.database.fichaTreinoDao.observarAtivas(),
                    builder: (context, snapshot) {
                      final fichas = snapshot.data ?? const <FichaTreino>[];

                      return DropdownButtonFormField<int>(
                        initialValue: _fichaTreinoId,
                        decoration: const InputDecoration(
                          labelText: 'Ficha vinculada',
                          prefixIcon: Icon(Icons.assignment_outlined),
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

                                  if (_nomeController.text.trim().isEmpty) {
                                    final ficha = fichas.firstWhere(
                                      (item) => item.id == valor,
                                    );
                                    _nomeController.text = ficha.nome;
                                  }
                                });
                              }
                            : null,
                        validator: (valor) {
                          if (_tipo == TipoPlanoTreinoItem.treino &&
                              valor == null) {
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
                    labelText: 'Código opcional',
                    hintText: 'A, B, C...',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeController,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    hintText: _nomePadrao(_tipo),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome da etapa.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoController,
                  maxLength: 500,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrição opcional',
                    hintText: 'Ex.: Peito, ombros e tríceps',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
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

  static String _nomePadrao(TipoPlanoTreinoItem tipo) {
    return switch (tipo) {
      TipoPlanoTreinoItem.treino => 'Treino',
      TipoPlanoTreinoItem.descanso => 'Descanso',
      TipoPlanoTreinoItem.cardio => 'Cardio',
      TipoPlanoTreinoItem.mobilidade => 'Mobilidade',
      TipoPlanoTreinoItem.personalizado => 'Etapa personalizada',
    };
  }

  static String? _textoOpcional(String valor) {
    final tratado = valor.trim();
    return tratado.isEmpty ? null : tratado;
  }
}
