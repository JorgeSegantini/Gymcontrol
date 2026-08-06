import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class GrupoMuscularFormDialog extends StatefulWidget {
  const GrupoMuscularFormDialog({
    required this.database,
    this.grupo,
    super.key,
  });

  final AppDatabase database;
  final GrupoMuscular? grupo;

  bool get editando => grupo != null;

  @override
  State<GrupoMuscularFormDialog> createState() =>
      _GrupoMuscularFormDialogState();
}

class _GrupoMuscularFormDialogState extends State<GrupoMuscularFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _ordemController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.grupo?.nome ?? '');

    _ordemController = TextEditingController(
      text: '${widget.grupo?.ordem ?? 0}',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ordemController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando) {
      return;
    }

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final nome = _nomeController.text.trim();
      final ordem = int.parse(_ordemController.text.trim());

      if (widget.editando) {
        await widget.database.grupoMuscularDao.editar(
          id: widget.grupo!.id,
          nome: nome,
          ordem: ordem,
        );
      } else {
        await widget.database.grupoMuscularDao.cadastrar(
          nome: nome,
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

      final mensagem =
          textoErro.contains('unique') ||
              textoErro.contains('grupos_musculares.nome')
          ? 'Já existe um grupo muscular com esse nome.'
          : widget.editando
          ? 'Não foi possível editar o grupo muscular.'
          : 'Não foi possível cadastrar o grupo muscular.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.editando ? 'Editar grupo muscular' : 'Novo grupo muscular',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                autofocus: true,
                enabled: !_salvando,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Peito',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final nome = valor?.trim() ?? '';

                  if (nome.isEmpty) {
                    return 'Informe o nome do grupo muscular.';
                  }

                  if (nome.length > 100) {
                    return 'O nome deve ter no máximo 100 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ordemController,
                enabled: !_salvando,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Ordem',
                  helperText: 'Define a posição do grupo na lista.',
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
                onFieldSubmitted: (_) {
                  _salvar();
                },
              ),
            ],
          ),
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
