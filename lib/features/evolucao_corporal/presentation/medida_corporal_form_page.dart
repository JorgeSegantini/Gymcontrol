import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class MedidaCorporalFormPage extends StatefulWidget {
  const MedidaCorporalFormPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<MedidaCorporalFormPage> createState() => _MedidaCorporalFormPageState();
}

class _MedidaCorporalFormPageState extends State<MedidaCorporalFormPage> {
  final Map<String, TextEditingController> _controllers = {
    for (final campo in _campos) campo.chave: TextEditingController(),
  };
  final TextEditingController _observacoesController = TextEditingController();

  DateTime _data = DateTime.now();
  bool _salvando = false;
  bool _carregandoData = true;
  MedidaCorporal? _existente;

  @override
  void initState() {
    super.initState();
    _carregarData(_data);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _carregarData(DateTime data) async {
    setState(() {
      _carregandoData = true;
    });

    final registro = await widget.database.medidaCorporalDao.obterPorData(data);

    if (!mounted) {
      return;
    }

    _existente = registro;
    _preencherControllers(registro);

    setState(() {
      _carregandoData = false;
    });
  }

  void _preencherControllers(MedidaCorporal? registro) {
    for (final campo in _campos) {
      final valor = registro == null ? null : campo.obter(registro);
      _controllers[campo.chave]!.text = valor == null
          ? ''
          : (valor / 10).toStringAsFixed(1).replaceAll('.', ',');
    }

    _observacoesController.text = registro?.observacoes ?? '';
  }

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selecionada == null) {
      return;
    }

    setState(() {
      _data = DateTime(selecionada.year, selecionada.month, selecionada.day);
    });

    await _carregarData(_data);
  }

  int? _lerMilimetros(String chave) {
    final texto = _controllers[chave]!.text.trim();
    if (texto.isEmpty) {
      return null;
    }

    final valor = double.tryParse(texto.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      throw const FormatException('medida');
    }

    return (valor * 10).round();
  }

  Future<void> _salvar() async {
    if (_salvando) {
      return;
    }

    late final Map<String, int?> valores;
    try {
      valores = {
        for (final campo in _campos) campo.chave: _lerMilimetros(campo.chave),
      };
    } on FormatException {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Revise as medidas. Use apenas valores maiores que zero.',
            ),
          ),
        );
      return;
    }

    if (!valores.values.any((valor) => valor != null)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Informe pelo menos uma medida corporal.'),
          ),
        );
      return;
    }

    if (_existente != null) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Atualizar avaliação?'),
            content: Text(
              'Já existe uma avaliação em ${_formatarData(_data)}. '
              'Os valores desta tela substituirão o registro desse dia.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Atualizar'),
              ),
            ],
          );
        },
      );

      if (confirmar != true) {
        return;
      }
    }

    setState(() {
      _salvando = true;
    });

    try {
      await widget.database.medidaCorporalDao.salvar(
        data: _data,
        pescocoMilimetros: valores['pescoco'],
        ombrosMilimetros: valores['ombros'],
        peitoMilimetros: valores['peito'],
        cinturaMilimetros: valores['cintura'],
        abdomenMilimetros: valores['abdomen'],
        quadrilMilimetros: valores['quadril'],
        bracoDireitoMilimetros: valores['bracoDireito'],
        bracoEsquerdoMilimetros: valores['bracoEsquerdo'],
        coxaDireitaMilimetros: valores['coxaDireita'],
        coxaEsquerdaMilimetros: valores['coxaEsquerda'],
        panturrilhaDireitaMilimetros: valores['panturrilhaDireita'],
        panturrilhaEsquerdaMilimetros: valores['panturrilhaEsquerda'],
        observacoes: _observacoesController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ArgumentError catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(erro.message?.toString() ?? 'Dados inválidos.'),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar as medidas.')),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar medidas')),
      body: _carregandoData
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data da avaliação',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _selecionarData,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_formatarData(_data)),
                        ),
                        if (_existente != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Já existe uma avaliação nesta data. Os campos foram preenchidos para atualização.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _GrupoFormulario(
                  titulo: 'Tronco',
                  campos: _campos
                      .where((c) => c.grupo == _Grupo.tronco)
                      .toList(),
                  controllers: _controllers,
                ),
                const SizedBox(height: 12),
                _GrupoFormulario(
                  titulo: 'Braços',
                  campos: _campos
                      .where((c) => c.grupo == _Grupo.bracos)
                      .toList(),
                  controllers: _controllers,
                ),
                const SizedBox(height: 12),
                _GrupoFormulario(
                  titulo: 'Pernas',
                  campos: _campos
                      .where((c) => c.grupo == _Grupo.pernas)
                      .toList(),
                  controllers: _controllers,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _observacoesController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        hintText: 'Opcional',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar medidas'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você pode preencher somente as medidas que deseja acompanhar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GrupoFormulario extends StatelessWidget {
  const _GrupoFormulario({
    required this.titulo,
    required this.campos,
    required this.controllers,
  });

  final String titulo;
  final List<_CampoDefinicao> campos;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < campos.length; index++) ...[
              TextField(
                controller: controllers[campos[index].chave],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: campos[index].rotulo,
                  suffixText: 'cm',
                ),
              ),
              if (index < campos.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Grupo { tronco, bracos, pernas }

class _CampoDefinicao {
  const _CampoDefinicao({
    required this.chave,
    required this.rotulo,
    required this.grupo,
    required this.obter,
  });

  final String chave;
  final String rotulo;
  final _Grupo grupo;
  final int? Function(MedidaCorporal registro) obter;
}

final List<_CampoDefinicao> _campos = [
  _CampoDefinicao(
    chave: 'pescoco',
    rotulo: 'Pescoço',
    grupo: _Grupo.tronco,
    obter: (r) => r.pescocoMilimetros,
  ),
  _CampoDefinicao(
    chave: 'ombros',
    rotulo: 'Ombros',
    grupo: _Grupo.tronco,
    obter: (r) => r.ombrosMilimetros,
  ),
  _CampoDefinicao(
    chave: 'peito',
    rotulo: 'Peito',
    grupo: _Grupo.tronco,
    obter: (r) => r.peitoMilimetros,
  ),
  _CampoDefinicao(
    chave: 'cintura',
    rotulo: 'Cintura',
    grupo: _Grupo.tronco,
    obter: (r) => r.cinturaMilimetros,
  ),
  _CampoDefinicao(
    chave: 'abdomen',
    rotulo: 'Abdômen',
    grupo: _Grupo.tronco,
    obter: (r) => r.abdomenMilimetros,
  ),
  _CampoDefinicao(
    chave: 'quadril',
    rotulo: 'Quadril',
    grupo: _Grupo.tronco,
    obter: (r) => r.quadrilMilimetros,
  ),
  _CampoDefinicao(
    chave: 'bracoDireito',
    rotulo: 'Braço direito',
    grupo: _Grupo.bracos,
    obter: (r) => r.bracoDireitoMilimetros,
  ),
  _CampoDefinicao(
    chave: 'bracoEsquerdo',
    rotulo: 'Braço esquerdo',
    grupo: _Grupo.bracos,
    obter: (r) => r.bracoEsquerdoMilimetros,
  ),
  _CampoDefinicao(
    chave: 'coxaDireita',
    rotulo: 'Coxa direita',
    grupo: _Grupo.pernas,
    obter: (r) => r.coxaDireitaMilimetros,
  ),
  _CampoDefinicao(
    chave: 'coxaEsquerda',
    rotulo: 'Coxa esquerda',
    grupo: _Grupo.pernas,
    obter: (r) => r.coxaEsquerdaMilimetros,
  ),
  _CampoDefinicao(
    chave: 'panturrilhaDireita',
    rotulo: 'Panturrilha direita',
    grupo: _Grupo.pernas,
    obter: (r) => r.panturrilhaDireitaMilimetros,
  ),
  _CampoDefinicao(
    chave: 'panturrilhaEsquerda',
    rotulo: 'Panturrilha esquerda',
    grupo: _Grupo.pernas,
    obter: (r) => r.panturrilhaEsquerdaMilimetros,
  ),
];

String _formatarData(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';
}
