import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class FichaTreinoFormDialog extends StatefulWidget {
  const FichaTreinoFormDialog({
    required this.database,
    this.fichaTreino,
    super.key,
  });

  final AppDatabase database;
  final FichaTreino? fichaTreino;

  @override
  State<FichaTreinoFormDialog> createState() => _FichaTreinoFormDialogState();
}

class _FichaTreinoFormDialogState extends State<FichaTreinoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _ordemController;

  bool _salvando = false;

  bool get _editando => widget.fichaTreino != null;

  @override
  void initState() {
    super.initState();

    final ficha = widget.fichaTreino;

    _nomeController = TextEditingController(text: ficha?.nome ?? '');

    _descricaoController = TextEditingController(text: ficha?.descricao ?? '');

    _ordemController = TextEditingController(
      text: ficha?.ordem.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _ordemController.dispose();

    super.dispose();
  }

  String? _validarNome(String? valor) {
    final nome = valor?.trim() ?? '';

    if (nome.isEmpty) {
      return 'Informe o nome da ficha.';
    }

    if (nome.length > 100) {
      return 'O nome deve ter no máximo 100 caracteres.';
    }

    return null;
  }

  String? _validarDescricao(String? valor) {
    final descricao = valor?.trim() ?? '';

    if (descricao.length > 1000) {
      return 'A descrição deve ter no máximo 1000 caracteres.';
    }

    return null;
  }

  String? _validarOrdem(String? valor) {
    final ordem = int.tryParse(valor?.trim() ?? '');

    if (ordem == null) {
      return 'Informe uma ordem válida.';
    }

    if (ordem < 0) {
      return 'A ordem não pode ser negativa.';
    }

    return null;
  }

  Future<void> _salvar() async {
    if (_salvando || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final ordem = int.parse(_ordemController.text.trim());

    try {
      if (_editando) {
        final alterado = await widget.database.fichaTreinoDao.editar(
          id: widget.fichaTreino!.id,
          nome: nome,
          descricao: descricao,
          ordem: ordem,
        );

        if (!alterado) {
          throw StateError('A ficha de treino não foi encontrada.');
        }
      } else {
        await widget.database.fichaTreinoDao.cadastrar(
          nome: nome,
          descricao: descricao,
          ordem: ordem,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!mounted) {
        return;
      }

      final textoErro = erro.toString().toLowerCase();

      final mensagem =
          textoErro.contains('unique') ||
              textoErro.contains('fichas_treino.nome')
          ? 'Já existe uma ficha com esse nome.'
          : 'Não foi possível salvar a ficha de treino.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
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
    return AlertDialog(
      title: Text(
        _editando ? 'Editar ficha de treino' : 'Nova ficha de treino',
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  autofocus: true,
                  enabled: !_salvando,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Exemplo: Treino A',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarNome,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  enabled: !_salvando,
                  maxLength: 1000,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descrição opcional da ficha',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarDescricao,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ordemController,
                  enabled: !_salvando,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ordem',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarOrdem,
                ),
              ],
            ),
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
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
