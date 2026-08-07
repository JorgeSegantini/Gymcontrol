import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'medida_corporal_form_page.dart';

class EvolucaoCorporalPage extends StatefulWidget {
  const EvolucaoCorporalPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<EvolucaoCorporalPage> createState() => _EvolucaoCorporalPageState();
}

class _EvolucaoCorporalPageState extends State<EvolucaoCorporalPage> {
  late Future<_EvolucaoCorporalDados> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _dadosFuture = _buscarDados();
  }

  Future<_EvolucaoCorporalDados> _buscarDados() async {
    final resultados = await Future.wait<Object>([
      widget.database.pesoCorporalDao.listarHistorico(),
      widget.database.medidaCorporalDao.listarHistorico(),
    ]);

    return _EvolucaoCorporalDados(
      pesos: resultados[0] as List<PesoCorporal>,
      medidas: resultados[1] as List<MedidaCorporal>,
    );
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _dadosFuture;
  }

  Future<void> _registrarPeso() async {
    final resultado = await showDialog<_PesoDialogResultado>(
      context: context,
      builder: (context) => const _PesoDialog(),
    );

    if (resultado == null || !mounted) {
      return;
    }

    final existente = await widget.database.pesoCorporalDao.obterPorData(
      resultado.data,
    );

    if (!mounted) {
      return;
    }

    if (existente != null) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Atualizar pesagem?'),
            content: Text(
              'Já existe uma pesagem em ${_formatarData(resultado.data)}. '
              'Deseja substituir ${_formatarPeso(existente.pesoGramas)} '
              'por ${_formatarPeso(resultado.pesoGramas)}?',
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

    try {
      await widget.database.pesoCorporalDao.salvar(
        data: resultado.data,
        pesoGramas: resultado.pesoGramas,
      );

      if (!mounted) {
        return;
      }

      setState(_carregar);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              existente == null ? 'Pesagem registrada.' : 'Pesagem atualizada.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar a pesagem.')),
        );
    }
  }

  Future<void> _registrarMedidas() async {
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MedidaCorporalFormPage(database: widget.database),
      ),
    );

    if (alterou == true && mounted) {
      setState(_carregar);
    }
  }

  void _mostrarPesagens(List<PesoCorporal> pesos) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Últimas pesagens',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: pesos.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Nenhuma pesagem registrada.'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: pesos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final peso = pesos[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.monitor_weight_outlined),
                                ),
                                title: Text(
                                  _formatarPeso(peso.pesoGramas),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(_formatarData(peso.data)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarAvaliacoes(List<MedidaCorporal> medidas) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Avaliações corporais',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: medidas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Nenhuma avaliação registrada.'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: medidas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final avaliacao = medidas[index];
                            final quantidade = _contarMedidas(avaliacao);
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.straighten_outlined),
                                ),
                                title: Text(
                                  _formatarData(avaliacao.data),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '$quantidade ${quantidade == 1 ? 'medida registrada' : 'medidas registradas'}',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarHistoricoCompleto(_EvolucaoCorporalDados dados) {
    final itens = _montarHistorico(dados);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Histórico corporal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: itens.isEmpty
                      ? const Center(child: Text('Nenhum registro corporal.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: itens.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) =>
                              _HistoricoItemCard(item: itens[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evolução corporal')),
      body: FutureBuilder<_EvolucaoCorporalDados>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EstadoErro(onTentarNovamente: () => setState(_carregar));
          }

          final dados = snapshot.data ?? const _EvolucaoCorporalDados();
          final historico = _montarHistorico(dados);

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _PesoAtualCard(
                  pesos: dados.pesos,
                  onRegistrar: _registrarPeso,
                  onVerPesagens: () => _mostrarPesagens(dados.pesos),
                ),
                const SizedBox(height: 20),
                _MedidasSecao(
                  medidas: dados.medidas,
                  onRegistrar: _registrarMedidas,
                  onVerAvaliacoes: () => _mostrarAvaliacoes(dados.medidas),
                ),
                const SizedBox(height: 24),
                _HistoricoSecao(
                  itens: historico.take(10).toList(),
                  possuiMais: historico.length > 10,
                  onVerCompleto: () => _mostrarHistoricoCompleto(dados),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PesoAtualCard extends StatelessWidget {
  const _PesoAtualCard({
    required this.pesos,
    required this.onRegistrar,
    required this.onVerPesagens,
  });

  final List<PesoCorporal> pesos;
  final VoidCallback onRegistrar;
  final VoidCallback onVerPesagens;

  @override
  Widget build(BuildContext context) {
    final atual = pesos.isEmpty ? null : pesos.first;
    final primeiro = pesos.isEmpty ? null : pesos.last;
    final variacao = atual == null || primeiro == null
        ? null
        : atual.pesoGramas - primeiro.pesoGramas;

    String subtitulo;
    IconData? iconeVariacao;

    if (atual == null) {
      subtitulo = 'Registre sua primeira pesagem.';
    } else if (pesos.length == 1 || variacao == 0) {
      subtitulo = pesos.length == 1
          ? 'Primeiro registro em ${_formatarDataCurta(atual.data)}'
          : 'Sem variação desde ${_formatarDataCurta(primeiro!.data)}';
    } else {
      iconeVariacao = variacao! < 0 ? Icons.arrow_downward : Icons.arrow_upward;
      subtitulo =
          '${_formatarVariacaoPeso(variacao.abs())} desde '
          '${_formatarDataCurta(primeiro!.data)}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peso atual',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              atual == null ? '—' : _formatarPeso(atual.pesoGramas),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (iconeVariacao != null) ...[
                  Icon(iconeVariacao, size: 18),
                  const SizedBox(width: 4),
                ],
                Expanded(child: Text(subtitulo)),
              ],
            ),
            if (pesos.length >= 2) ...[
              const SizedBox(height: 16),
              _GraficoPeso(pesos: pesos),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRegistrar,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar peso'),
                ),
                OutlinedButton.icon(
                  onPressed: onVerPesagens,
                  icon: const Icon(Icons.history),
                  label: const Text('Ver pesagens'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficoPeso extends StatelessWidget {
  const _GraficoPeso({required this.pesos});

  final List<PesoCorporal> pesos;

  @override
  Widget build(BuildContext context) {
    final selecionados = pesos.take(5).toList().reversed.toList();
    final pontos = [
      for (final peso in selecionados)
        _GraficoPonto(data: peso.data, valor: peso.pesoGramas / 1000),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evolução do peso',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${selecionados.length} ${selecionados.length == 1 ? 'registro' : 'registros'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: _GraficoLinha(
              pontos: pontos,
              cor: Theme.of(context).colorScheme.primary,
              referencias: const [50, 75, 100],
              unidade: 'kg',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatarDataCurta(selecionados.first.data),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatarDataCurta(selecionados.last.data),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvolucaoMedidasCard extends StatefulWidget {
  const _EvolucaoMedidasCard({required this.historico});

  final List<MedidaCorporal> historico;

  @override
  State<_EvolucaoMedidasCard> createState() => _EvolucaoMedidasCardState();
}

class _EvolucaoMedidasCardState extends State<_EvolucaoMedidasCard> {
  _MedidaDefinicao? _selecionada;

  List<_MedidaDefinicao> get _disponiveis {
    return _todasMedidas.where((definicao) {
      return widget.historico.any(
        (registro) => definicao.obter(registro) != null,
      );
    }).toList();
  }

  _MedidaDefinicao? _resolverSelecionada(List<_MedidaDefinicao> disponiveis) {
    if (disponiveis.isEmpty) {
      return null;
    }

    if (_selecionada != null && disponiveis.contains(_selecionada)) {
      return _selecionada;
    }

    for (final definicao in disponiveis) {
      if (definicao.rotulo == 'Cintura') {
        return definicao;
      }
    }

    return disponiveis.first;
  }

  @override
  Widget build(BuildContext context) {
    final disponiveis = _disponiveis;
    final selecionada = _resolverSelecionada(disponiveis);

    if (selecionada == null) {
      return const SizedBox.shrink();
    }

    final registros = <_GraficoPonto>[];
    for (final registro in widget.historico.reversed) {
      final valor = selecionada.obter(registro);
      if (valor != null) {
        registros.add(_GraficoPonto(data: registro.data, valor: valor / 10));
      }
    }

    final atual = registros.isEmpty ? null : registros.last;
    final primeiro = registros.isEmpty ? null : registros.first;
    final variacao = atual == null || primeiro == null
        ? null
        : ((atual.valor - primeiro.valor) * 10).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução das medidas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Escolha uma medida para acompanhar sua evolução.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<_MedidaDefinicao>(
              value: selecionada,
              isExpanded: true,
              items: [
                for (final definicao in disponiveis)
                  DropdownMenuItem<_MedidaDefinicao>(
                    value: definicao,
                    child: Text(definicao.rotulo),
                  ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _selecionada = valor);
                }
              },
            ),
            const SizedBox(height: 8),
            if (atual != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${atual.valor.toStringAsFixed(1).replaceAll('.', ',')} cm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (variacao != null && registros.length >= 2) ...[
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (variacao != 0)
                            Icon(
                              variacao > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 17,
                            ),
                          if (variacao != 0) const SizedBox(width: 2),
                          Text(
                            variacao == 0
                                ? 'sem variação'
                                : '${_formatarVariacaoMedida(variacao.abs())} desde ${_formatarDataCurta(primeiro!.data)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
            ],
            if (registros.length < 2)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Registre esta medida em outra data para visualizar o gráfico de evolução.',
                ),
              )
            else ...[
              SizedBox(
                height: 150,
                width: double.infinity,
                child: _GraficoLinha(
                  pontos: registros,
                  cor: Theme.of(context).colorScheme.primary,
                  referencias: _criarReferenciasMedidas(registros),
                  unidade: 'cm',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatarDataCurta(registros.first.data),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatarDataCurta(registros.last.data),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GraficoLinha extends StatelessWidget {
  const _GraficoLinha({
    required this.pontos,
    required this.cor,
    required this.referencias,
    required this.unidade,
  });

  final List<_GraficoPonto> pontos;
  final Color cor;
  final List<double> referencias;
  final String unidade;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GraficoLinhaPainter(
        pontos: pontos,
        cor: cor,
        grade: Theme.of(context).colorScheme.outlineVariant,
        texto: Theme.of(context).colorScheme.onSurfaceVariant,
        referencias: referencias,
        unidade: unidade,
      ),
    );
  }
}

class _GraficoLinhaPainter extends CustomPainter {
  _GraficoLinhaPainter({
    required this.pontos,
    required this.cor,
    required this.grade,
    required this.texto,
    required this.referencias,
    required this.unidade,
  });

  final List<_GraficoPonto> pontos;
  final Color cor;
  final Color grade;
  final Color texto;
  final List<double> referencias;
  final String unidade;

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    const margemEsquerda = 48.0;
    const margemDireita = 8.0;
    const margemSuperior = 26.0;
    const margemInferior = 10.0;
    final largura = size.width - margemEsquerda - margemDireita;
    final altura = size.height - margemSuperior - margemInferior;

    var minimo = pontos.first.valor;
    var maximo = pontos.first.valor;
    for (final ponto in pontos.skip(1)) {
      if (ponto.valor < minimo) minimo = ponto.valor;
      if (ponto.valor > maximo) maximo = ponto.valor;
    }
    for (final referencia in referencias) {
      if (referencia < minimo) minimo = referencia;
      if (referencia > maximo) maximo = referencia;
    }

    var intervalo = maximo - minimo;
    if (intervalo == 0) {
      intervalo = maximo.abs() * 0.02;
      if (intervalo == 0) intervalo = 1;
      minimo -= intervalo;
      maximo += intervalo;
      intervalo = maximo - minimo;
    } else if (referencias.isEmpty) {
      final folga = intervalo * 0.18;
      minimo -= folga;
      maximo += folga;
      intervalo = maximo - minimo;
    }

    final tintaGrade = Paint()
      ..color = grade
      ..strokeWidth = 1;

    for (final referencia in referencias) {
      final proporcaoY = (referencia - minimo) / intervalo;
      final y = margemSuperior + altura - (proporcaoY * altura);
      canvas.drawLine(
        Offset(margemEsquerda, y),
        Offset(size.width - margemDireita, y),
        tintaGrade,
      );

      final rotulo = _formatarReferenciaGrafico(referencia, unidade);
      final textPainter = TextPainter(
        text: TextSpan(
          text: rotulo,
          style: TextStyle(
            color: texto,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: margemEsquerda - 6);
      textPainter.paint(
        canvas,
        Offset(
          margemEsquerda - textPainter.width - 6,
          y - (textPainter.height / 2),
        ),
      );
    }

    final caminho = Path();
    final offsets = <Offset>[];
    for (var index = 0; index < pontos.length; index++) {
      final x = pontos.length == 1
          ? margemEsquerda + (largura / 2)
          : margemEsquerda + (largura * index / (pontos.length - 1));
      final proporcaoY = (pontos[index].valor - minimo) / intervalo;
      final y = margemSuperior + altura - (proporcaoY * altura);
      final offset = Offset(x, y);
      offsets.add(offset);
      if (index == 0) {
        caminho.moveTo(offset.dx, offset.dy);
      } else {
        caminho.lineTo(offset.dx, offset.dy);
      }
    }

    final tintaLinha = Paint()
      ..color = cor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(caminho, tintaLinha);

    final tintaPonto = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;
    for (final offset in offsets) {
      canvas.drawCircle(offset, 3.5, tintaPonto);
    }

    final indicesRotulados = _indicesParaRotularPontos(pontos.length);
    for (final index in indicesRotulados) {
      final offset = offsets[index];
      final rotulo = _formatarValorPonto(pontos[index].valor);
      final textPainter = TextPainter(
        text: TextSpan(
          text: rotulo,
          style: TextStyle(
            color: texto,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      var x = offset.dx - (textPainter.width / 2);
      if (x < margemEsquerda) {
        x = margemEsquerda;
      } else if (x + textPainter.width > size.width - margemDireita) {
        x = size.width - margemDireita - textPainter.width;
      }

      final y = (offset.dy - textPainter.height - 6).clamp(0.0, size.height);
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _GraficoLinhaPainter oldDelegate) {
    return oldDelegate.pontos != pontos ||
        oldDelegate.cor != cor ||
        oldDelegate.grade != grade ||
        oldDelegate.texto != texto ||
        oldDelegate.referencias != referencias ||
        oldDelegate.unidade != unidade;
  }
}

Set<int> _indicesParaRotularPontos(int quantidade) {
  if (quantidade <= 0) {
    return const <int>{};
  }

  if (quantidade <= 6) {
    return {for (var index = 0; index < quantidade; index++) index};
  }

  final passo = quantidade <= 9 ? 2 : 3;
  final indices = <int>{0, quantidade - 1};
  for (var index = passo; index < quantidade - 1; index += passo) {
    indices.add(index);
  }
  return indices;
}

String _formatarValorPonto(double valor) {
  return valor.toStringAsFixed(1).replaceAll('.', ',');
}

List<double> _criarReferenciasMedidas(List<_GraficoPonto> pontos) {
  if (pontos.isEmpty) {
    return const [];
  }

  var minimo = pontos.first.valor;
  var maximo = pontos.first.valor;
  for (final ponto in pontos.skip(1)) {
    if (ponto.valor < minimo) minimo = ponto.valor;
    if (ponto.valor > maximo) maximo = ponto.valor;
  }

  if (minimo == maximo) {
    final margem = minimo.abs() * 0.03 < 1 ? 1.0 : minimo.abs() * 0.03;
    minimo -= margem;
    maximo += margem;
  } else {
    final margem = (maximo - minimo) * 0.2;
    minimo -= margem;
    maximo += margem;
  }

  final passoBruto = (maximo - minimo) / 2;
  final passo = _arredondarPassoGrafico(passoBruto);
  final centro = ((minimo + maximo) / 2 / passo).round() * passo;

  return [centro - passo, centro, centro + passo];
}

double _arredondarPassoGrafico(double valor) {
  if (valor <= 0.5) return 0.5;
  if (valor <= 1) return 1;
  if (valor <= 2) return 2;
  if (valor <= 2.5) return 2.5;
  if (valor <= 5) return 5;
  if (valor <= 10) return 10;
  if (valor <= 20) return 20;
  return 25;
}

String _formatarReferenciaGrafico(double valor, String unidade) {
  final inteiro = valor == valor.roundToDouble();
  final texto = inteiro
      ? valor.toStringAsFixed(0)
      : valor.toStringAsFixed(1).replaceAll('.', ',');
  return '$texto $unidade';
}

class _GraficoPonto {
  const _GraficoPonto({required this.data, required this.valor});

  final DateTime data;
  final double valor;
}

class _MedidasSecao extends StatelessWidget {
  const _MedidasSecao({
    required this.medidas,
    required this.onRegistrar,
    required this.onVerAvaliacoes,
  });

  final List<MedidaCorporal> medidas;
  final VoidCallback onRegistrar;
  final VoidCallback onVerAvaliacoes;

  @override
  Widget build(BuildContext context) {
    final ultimaAvaliacao = medidas.isEmpty ? null : medidas.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medidas corporais',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          ultimaAvaliacao == null
              ? 'Nenhuma avaliação registrada.'
              : 'Última avaliação: ${_formatarData(ultimaAvaliacao.data)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onRegistrar,
              icon: const Icon(Icons.add),
              label: const Text('Registrar medidas'),
            ),
            OutlinedButton.icon(
              onPressed: onVerAvaliacoes,
              icon: const Icon(Icons.history),
              label: const Text('Ver avaliações'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (medidas.isEmpty)
          const _MedidasVazias()
        else ...[
          _GrupoMedidasCard(
            titulo: 'Tronco',
            definicoes: _medidasTronco,
            historico: medidas,
          ),
          const SizedBox(height: 10),
          _GrupoMedidasCard(
            titulo: 'Braços',
            definicoes: _medidasBracos,
            historico: medidas,
          ),
          const SizedBox(height: 10),
          _GrupoMedidasCard(
            titulo: 'Pernas',
            definicoes: _medidasPernas,
            historico: medidas,
          ),
          const SizedBox(height: 14),
          _EvolucaoMedidasCard(historico: medidas),
        ],
      ],
    );
  }
}

class _GrupoMedidasCard extends StatelessWidget {
  const _GrupoMedidasCard({
    required this.titulo,
    required this.definicoes,
    required this.historico,
  });

  final String titulo;
  final List<_MedidaDefinicao> definicoes;
  final List<MedidaCorporal> historico;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < definicoes.length; index++) ...[
              _MedidaLinha(definicao: definicoes[index], historico: historico),
              if (index < definicoes.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _MedidaLinha extends StatelessWidget {
  const _MedidaLinha({required this.definicao, required this.historico});

  final _MedidaDefinicao definicao;
  final List<MedidaCorporal> historico;

  @override
  Widget build(BuildContext context) {
    final valores = <int>[];

    for (final registro in historico) {
      final valor = definicao.obter(registro);
      if (valor != null) {
        valores.add(valor);
        if (valores.length == 2) {
          break;
        }
      }
    }

    final atual = valores.isEmpty ? null : valores.first;
    final anterior = valores.length < 2 ? null : valores[1];
    final diferenca = atual == null || anterior == null
        ? null
        : atual - anterior;

    IconData? icone;
    if (diferenca != null && diferenca != 0) {
      icone = diferenca > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              definicao.rotulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            atual == null ? '—' : _formatarMedida(atual),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 82,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icone != null) Icon(icone, size: 17),
                if (icone != null) const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    diferenca == null
                        ? '—'
                        : diferenca == 0
                        ? '0 cm'
                        : _formatarVariacaoMedida(diferenca.abs()),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedidasVazias extends StatelessWidget {
  const _MedidasVazias();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.straighten_outlined, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Registre sua primeira avaliação para acompanhar as medidas por grupo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricoSecao extends StatelessWidget {
  const _HistoricoSecao({
    required this.itens,
    required this.possuiMais,
    required this.onVerCompleto,
  });

  final List<_HistoricoCorporalItem> itens;
  final bool possuiMais;
  final VoidCallback onVerCompleto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Pesagens e avaliações mais recentes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (itens.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhum registro corporal até o momento.'),
            ),
          )
        else
          for (var index = 0; index < itens.length; index++) ...[
            _HistoricoItemCard(item: itens[index]),
            if (index < itens.length - 1) const SizedBox(height: 6),
          ],
        if (possuiMais) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onVerCompleto,
              icon: const Icon(Icons.history),
              label: const Text('Ver histórico completo'),
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoricoItemCard extends StatelessWidget {
  const _HistoricoItemCard({required this.item});

  final _HistoricoCorporalItem item;

  @override
  Widget build(BuildContext context) {
    final isPeso = item.tipo == _HistoricoTipo.peso;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isPeso ? Icons.monitor_weight_outlined : Icons.straighten_outlined,
          ),
        ),
        title: Text(
          isPeso ? 'Peso — ${item.descricao}' : 'Medidas corporais',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          isPeso
              ? _formatarData(item.data)
              : '${_formatarData(item.data)} • ${item.descricao}',
        ),
      ),
    );
  }
}

class _EstadoErro extends StatelessWidget {
  const _EstadoErro({required this.onTentarNovamente});

  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52),
            const SizedBox(height: 14),
            const Text(
              'Não foi possível carregar a evolução corporal.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PesoDialog extends StatefulWidget {
  const _PesoDialog();

  @override
  State<_PesoDialog> createState() => _PesoDialogState();
}

class _PesoDialogState extends State<_PesoDialog> {
  final TextEditingController _pesoController = TextEditingController();
  DateTime _data = DateTime.now();
  String? _erro;

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selecionada != null) {
      setState(() {
        _data = selecionada;
      });
    }
  }

  void _salvar() {
    final valor = double.tryParse(
      _pesoController.text.trim().replaceAll(',', '.'),
    );

    if (valor == null || valor <= 0) {
      setState(() {
        _erro = 'Informe um peso válido.';
      });
      return;
    }

    Navigator.of(context).pop(
      _PesoDialogResultado(
        data: DateTime(_data.year, _data.month, _data.day),
        pesoGramas: (valor * 1000).round(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar peso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _selecionarData,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(_formatarData(_data)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pesoController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Peso',
                suffixText: 'kg',
                errorText: _erro,
              ),
              onSubmitted: (_) => _salvar(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}

class _PesoDialogResultado {
  const _PesoDialogResultado({required this.data, required this.pesoGramas});

  final DateTime data;
  final int pesoGramas;
}

class _EvolucaoCorporalDados {
  const _EvolucaoCorporalDados({
    this.pesos = const <PesoCorporal>[],
    this.medidas = const <MedidaCorporal>[],
  });

  final List<PesoCorporal> pesos;
  final List<MedidaCorporal> medidas;
}

enum _HistoricoTipo { peso, medidas }

class _HistoricoCorporalItem {
  const _HistoricoCorporalItem({
    required this.data,
    required this.tipo,
    required this.descricao,
  });

  final DateTime data;
  final _HistoricoTipo tipo;
  final String descricao;
}

class _MedidaDefinicao {
  const _MedidaDefinicao({required this.rotulo, required this.obter});

  final String rotulo;
  final int? Function(MedidaCorporal registro) obter;
}

final List<_MedidaDefinicao> _medidasTronco = [
  _MedidaDefinicao(rotulo: 'Pescoço', obter: (r) => r.pescocoMilimetros),
  _MedidaDefinicao(rotulo: 'Ombros', obter: (r) => r.ombrosMilimetros),
  _MedidaDefinicao(rotulo: 'Peito', obter: (r) => r.peitoMilimetros),
  _MedidaDefinicao(rotulo: 'Cintura', obter: (r) => r.cinturaMilimetros),
  _MedidaDefinicao(rotulo: 'Abdômen', obter: (r) => r.abdomenMilimetros),
  _MedidaDefinicao(rotulo: 'Quadril', obter: (r) => r.quadrilMilimetros),
];

final List<_MedidaDefinicao> _medidasBracos = [
  _MedidaDefinicao(
    rotulo: 'Braço direito',
    obter: (r) => r.bracoDireitoMilimetros,
  ),
  _MedidaDefinicao(
    rotulo: 'Braço esquerdo',
    obter: (r) => r.bracoEsquerdoMilimetros,
  ),
];

final List<_MedidaDefinicao> _medidasPernas = [
  _MedidaDefinicao(
    rotulo: 'Coxa direita',
    obter: (r) => r.coxaDireitaMilimetros,
  ),
  _MedidaDefinicao(
    rotulo: 'Coxa esquerda',
    obter: (r) => r.coxaEsquerdaMilimetros,
  ),
  _MedidaDefinicao(
    rotulo: 'Panturrilha direita',
    obter: (r) => r.panturrilhaDireitaMilimetros,
  ),
  _MedidaDefinicao(
    rotulo: 'Panturrilha esquerda',
    obter: (r) => r.panturrilhaEsquerdaMilimetros,
  ),
];

final List<_MedidaDefinicao> _todasMedidas = [
  ..._medidasTronco,
  ..._medidasBracos,
  ..._medidasPernas,
];

List<_HistoricoCorporalItem> _montarHistorico(_EvolucaoCorporalDados dados) {
  final itens = <_HistoricoCorporalItem>[
    for (final peso in dados.pesos)
      _HistoricoCorporalItem(
        data: peso.data,
        tipo: _HistoricoTipo.peso,
        descricao: _formatarPeso(peso.pesoGramas),
      ),
    for (final medida in dados.medidas)
      _HistoricoCorporalItem(
        data: medida.data,
        tipo: _HistoricoTipo.medidas,
        descricao:
            '${_contarMedidas(medida)} ${_contarMedidas(medida) == 1 ? 'medida registrada' : 'medidas registradas'}',
      ),
  ];

  itens.sort((a, b) {
    final porData = b.data.compareTo(a.data);
    if (porData != 0) {
      return porData;
    }
    return a.tipo.index.compareTo(b.tipo.index);
  });

  return itens;
}

int _contarMedidas(MedidaCorporal registro) {
  return [
    registro.pescocoMilimetros,
    registro.ombrosMilimetros,
    registro.peitoMilimetros,
    registro.cinturaMilimetros,
    registro.abdomenMilimetros,
    registro.quadrilMilimetros,
    registro.bracoDireitoMilimetros,
    registro.bracoEsquerdoMilimetros,
    registro.coxaDireitaMilimetros,
    registro.coxaEsquerdaMilimetros,
    registro.panturrilhaDireitaMilimetros,
    registro.panturrilhaEsquerdaMilimetros,
  ].where((valor) => valor != null).length;
}

String _formatarPeso(int gramas) {
  final kg = gramas / 1000;
  return '${kg.toStringAsFixed(1).replaceAll('.', ',')} kg';
}

String _formatarVariacaoPeso(int gramas) {
  final kg = gramas / 1000;
  return '${kg.toStringAsFixed(1).replaceAll('.', ',')} kg';
}

String _formatarMedida(int milimetros) {
  final cm = milimetros / 10;
  return '${cm.toStringAsFixed(1).replaceAll('.', ',')} cm';
}

String _formatarVariacaoMedida(int milimetros) {
  final cm = milimetros / 10;
  return '${cm.toStringAsFixed(1).replaceAll('.', ',')} cm';
}

String _formatarData(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';
}

String _formatarDataCurta(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}';
}
