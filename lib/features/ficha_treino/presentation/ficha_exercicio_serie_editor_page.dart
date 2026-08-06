import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class FichaExercicioSerieEditorPage extends StatefulWidget {
  const FichaExercicioSerieEditorPage({
    required this.database,
    required this.serie,
    super.key,
  });

  final AppDatabase database;
  final FichaExercicioSerie serie;

  @override
  State<FichaExercicioSerieEditorPage> createState() =>
      _FichaExercicioSerieEditorPageState();
}

class _FichaExercicioSerieEditorPageState
    extends State<FichaExercicioSerieEditorPage> {
  final _formKey = GlobalKey<FormState>();

  late TipoSerie _tipoSerie;

  late final TextEditingController _repeticoesMinimasController;
  late final TextEditingController _repeticoesMaximasController;
  late final TextEditingController _cargaController;
  late final TextEditingController _incrementoController;
  late final TextEditingController _descansoController;
  late final TextEditingController _tempoController;
  late final TextEditingController _observacoesController;

  late bool _ativo;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _tipoSerie = TipoSerie.values.firstWhere(
      (tipo) => tipo.name == widget.serie.tipoSerie,
      orElse: () => TipoSerie.normal,
    );

    _ativo = widget.serie.ativo;

    _repeticoesMinimasController = TextEditingController(
      text: widget.serie.repeticoesMinimas?.toString() ?? '',
    );

    _repeticoesMaximasController = TextEditingController(
      text: widget.serie.repeticoesMaximas?.toString() ?? '',
    );

    _cargaController = TextEditingController(
      text: _formatarGramasComoQuilos(widget.serie.cargaPlanejadaGramas),
    );

    _incrementoController = TextEditingController(
      text: _formatarGramasComoQuilos(widget.serie.incrementoCargaGramas),
    );

    _descansoController = TextEditingController(
      text: widget.serie.descansoSegundos.toString(),
    );

    _tempoController = TextEditingController(
      text: widget.serie.tempoExecucaoSegundos?.toString() ?? '',
    );

    _observacoesController = TextEditingController(
      text: widget.serie.observacoes ?? '',
    );
  }

  @override
  void dispose() {
    _repeticoesMinimasController.dispose();
    _repeticoesMaximasController.dispose();
    _cargaController.dispose();
    _incrementoController.dispose();
    _descansoController.dispose();
    _tempoController.dispose();
    _observacoesController.dispose();

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

    final repeticoesMinimas = _converterInteiroOpcional(
      _repeticoesMinimasController.text,
    );

    final repeticoesMaximas = _converterInteiroOpcional(
      _repeticoesMaximasController.text,
    );

    if (repeticoesMinimas != null &&
        repeticoesMaximas != null &&
        repeticoesMinimas > repeticoesMaximas) {
      _mostrarErro(
        'As repetições mínimas não podem ser maiores que as máximas.',
      );
      return;
    }

    final cargaPlanejadaGramas = _converterQuilosParaGramas(
      _cargaController.text,
    );

    final incrementoCargaGramas = _converterQuilosParaGramas(
      _incrementoController.text,
    );

    final descansoSegundos =
        _converterInteiroOpcional(_descansoController.text) ?? 0;

    final tempoExecucaoSegundos = _converterInteiroOpcional(
      _tempoController.text,
    );

    setState(() {
      _salvando = true;
    });

    try {
      final alterada = await widget.database.fichaTreinoDao.editarSerie(
        id: widget.serie.id,
        tipoSerie: _tipoSerie,
        repeticoesMinimas: repeticoesMinimas,
        repeticoesMaximas: repeticoesMaximas,
        cargaPlanejadaGramas: cargaPlanejadaGramas,
        incrementoCargaGramas: incrementoCargaGramas,
        descansoSegundos: descansoSegundos,
        tempoExecucaoSegundos: tempoExecucaoSegundos,
        observacoes: _observacoesController.text,
        ativo: _ativo,
      );

      if (!mounted) {
        return;
      }

      if (!alterada) {
        throw StateError('A série não foi encontrada.');
      }

      Navigator.of(context).pop(true);
    } on ArgumentError catch (erro) {
      if (!mounted) {
        return;
      }

      _mostrarErro(_mensagemDaExcecao(erro.message));
    } catch (_) {
      if (!mounted) {
        return;
      }

      _mostrarErro('Não foi possível salvar a série.');
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String? _validarInteiroOpcional(String? valor, String nomeCampo) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return null;
    }

    final numero = int.tryParse(texto);

    if (numero == null) {
      return 'Informe um número inteiro válido.';
    }

    if (numero < 0) {
      return '$nomeCampo não pode ser negativo.';
    }

    return null;
  }

  String? _validarQuilosOpcional(String? valor, String nomeCampo) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return null;
    }

    final numero = double.tryParse(texto.replaceAll(',', '.'));

    if (numero == null) {
      return 'Informe um valor válido em kg.';
    }

    if (numero < 0) {
      return '$nomeCampo não pode ser negativa.';
    }

    return null;
  }

  int? _converterInteiroOpcional(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return null;
    }

    return int.parse(texto);
  }

  int? _converterQuilosParaGramas(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return null;
    }

    final quilos = double.parse(texto.replaceAll(',', '.'));

    return (quilos * 1000).round();
  }

  String _formatarGramasComoQuilos(int? gramas) {
    if (gramas == null) {
      return '';
    }

    final quilos = gramas / 1000;

    if (quilos == quilos.roundToDouble()) {
      return quilos.toInt().toString();
    }

    return quilos
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _mensagemDaExcecao(Object? mensagem) {
    final texto = mensagem?.toString().trim();

    if (texto == null || texto.isEmpty) {
      return 'Não foi possível concluir a operação.';
    }

    return texto;
  }

  String _nomeTipoSerie(TipoSerie tipo) {
    return switch (tipo) {
      TipoSerie.normal => 'Normal',
      TipoSerie.aquecimento => 'Aquecimento',
      TipoSerie.dropSet => 'Drop set',
      TipoSerie.restPause => 'Rest-pause',
      TipoSerie.biSet => 'Bi-set',
      TipoSerie.triSet => 'Tri-set',
      TipoSerie.cluster => 'Cluster',
      TipoSerie.isometrica => 'Isométrica',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Série ${widget.serie.ordem}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            DropdownButtonFormField<TipoSerie>(
              initialValue: _tipoSerie,
              decoration: const InputDecoration(
                labelText: 'Tipo da série',
                border: OutlineInputBorder(),
              ),
              items: TipoSerie.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(_nomeTipoSerie(tipo)),
                );
              }).toList(),
              onChanged: _salvando
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _tipoSerie = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repeticoesMinimasController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Repetições mínimas',
                hintText: 'Exemplo: 8',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (valor) {
                return _validarInteiroOpcional(valor, 'As repetições mínimas');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repeticoesMaximasController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Repetições máximas',
                hintText: 'Exemplo: 12',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (valor) {
                return _validarInteiroOpcional(valor, 'As repetições máximas');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cargaController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Carga planejada',
                hintText: 'Exemplo: 20 ou 22,5',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (valor) {
                return _validarQuilosOpcional(valor, 'A carga planejada');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incrementoController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Incremento de carga',
                hintText: 'Exemplo: 2,5',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (valor) {
                return _validarQuilosOpcional(valor, 'O incremento de carga');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descansoController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Descanso',
                hintText: 'Exemplo: 60',
                suffixText: 'segundos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (valor) {
                final texto = valor?.trim() ?? '';

                if (texto.isEmpty) {
                  return 'Informe o tempo de descanso.';
                }

                return _validarInteiroOpcional(valor, 'O descanso');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tempoController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Tempo de execução',
                hintText: 'Exemplo: 30',
                suffixText: 'segundos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (valor) {
                return _validarInteiroOpcional(valor, 'O tempo de execução');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacoesController,
              enabled: !_salvando,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Orientações para esta série',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _ativo,
              title: const Text('Série ativa'),
              subtitle: Text(
                _ativo
                    ? 'A série será utilizada no treino.'
                    : 'A série ficará preservada, mas não será utilizada.',
              ),
              onChanged: _salvando
                  ? null
                  : (value) {
                      setState(() {
                        _ativo = value;
                      });
                    },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
