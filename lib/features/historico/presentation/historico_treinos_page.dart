import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/historico_models.dart';
import '../data/historico_service.dart';
import 'widgets/historico_grupo_dia.dart';
import 'widgets/historico_vazio.dart';
import 'historico_treino_detalhes_page.dart';

class HistoricoTreinosPage extends StatefulWidget {
  const HistoricoTreinosPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<HistoricoTreinosPage> createState() => _HistoricoTreinosPageState();
}

class _HistoricoTreinosPageState extends State<HistoricoTreinosPage> {
  late Future<List<HistoricoGrupoDia>> _gruposFuture;

  HistoricoService get _service => HistoricoService(widget.database);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _gruposFuture = _service.listarGrupos();
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _gruposFuture;
  }

  Future<void> _abrirDetalhes(HistoricoTreinoResumo treino) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return HistoricoTreinoDetalhesPage(
            database: widget.database,
            treinoRealizadoId: treino.id,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: FutureBuilder<List<HistoricoGrupoDia>>(
        future: _gruposFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _HistoricoErro(
              onTentarNovamente: () {
                setState(_carregar);
              },
            );
          }

          final grupos = snapshot.data ?? const <HistoricoGrupoDia>[];

          if (grupos.isEmpty) {
            return const HistoricoVazio();
          }

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: grupos.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                return HistoricoGrupoDiaWidget(
                  grupo: grupos[index],
                  onTreinoTap: _abrirDetalhes,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoricoErro extends StatelessWidget {
  const _HistoricoErro({required this.onTentarNovamente});

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
              'Não foi possível carregar o histórico.',
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
