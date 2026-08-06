import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/evolucao_models.dart';
import '../data/evolucao_service.dart';
import 'widgets/campo_busca_exercicio.dart';
import 'widgets/evolucao_exercicio_card.dart';
import 'widgets/evolucao_vazia.dart';
import 'evolucao_exercicio_detalhes_page.dart';

class EvolucaoPage extends StatefulWidget {
  const EvolucaoPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<EvolucaoPage> createState() => _EvolucaoPageState();
}

class _EvolucaoPageState extends State<EvolucaoPage> {
  final TextEditingController _buscaController = TextEditingController();

  late Future<List<EvolucaoExercicioResumo>> _exerciciosFuture;
  String _termoBusca = '';

  EvolucaoService get _service => EvolucaoService(widget.database);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _carregar() {
    _exerciciosFuture = _service.listarExercicios();
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _exerciciosFuture;
  }

  void _alterarBusca(String valor) {
    setState(() {
      _termoBusca = valor.trim().toLowerCase();
    });
  }

  void _limparBusca() {
    _buscaController.clear();
    _alterarBusca('');
  }

  Future<void> _abrirDetalhes(EvolucaoExercicioResumo exercicio) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return EvolucaoExercicioDetalhesPage(
            database: widget.database,
            exercicio: exercicio,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evolução')),
      body: FutureBuilder<List<EvolucaoExercicioResumo>>(
        future: _exerciciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EvolucaoErro(
              onTentarNovamente: () {
                setState(_carregar);
              },
            );
          }

          final todos = snapshot.data ?? const <EvolucaoExercicioResumo>[];

          final filtrados = _termoBusca.isEmpty
              ? todos
              : todos.where((exercicio) {
                  return exercicio.nome.toLowerCase().contains(_termoBusca);
                }).toList();

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                CampoBuscaExercicio(
                  controller: _buscaController,
                  onChanged: _alterarBusca,
                  onLimpar: _limparBusca,
                ),
                const SizedBox(height: 16),
                if (filtrados.isEmpty)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.58,
                    child: EvolucaoVazia(possuiBusca: _termoBusca.isNotEmpty),
                  )
                else
                  for (var index = 0; index < filtrados.length; index++) ...[
                    EvolucaoExercicioCard(
                      exercicio: filtrados[index],
                      onTap: () {
                        _abrirDetalhes(filtrados[index]);
                      },
                    ),
                    if (index < filtrados.length - 1) const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EvolucaoErro extends StatelessWidget {
  const _EvolucaoErro({required this.onTentarNovamente});

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
              'Não foi possível carregar a evolução dos exercícios.',
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
