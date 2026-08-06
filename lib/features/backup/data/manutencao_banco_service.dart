import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'manutencao_banco_info.dart';

class ManutencaoBancoService {
  ManutencaoBancoService(this._database);

  final AppDatabase _database;

  Future<ManutencaoBancoInfo> obterInformacoes() async {
    final resultados = await Future.wait<int>([
      _contarTabela(_database.gruposMusculares),
      _contarTabela(_database.exercicios),
      _contarTabela(_database.fichasTreino),
      _contarTabela(_database.planosTreino),
      _contarTabela(_database.treinosRealizados),
      _contarTabela(_database.exerciciosRealizados),
      _contarTabela(_database.seriesRealizadas),
      _contarTabela(_database.planosTreinoExecucoes),
    ]);

    return ManutencaoBancoInfo(
      gruposMusculares: resultados[0],
      exercicios: resultados[1],
      fichasTreino: resultados[2],
      planosTreino: resultados[3],
      treinosRealizados: resultados[4],
      exerciciosRealizados: resultados[5],
      seriesRealizadas: resultados[6],
      execucoesPlano: resultados[7],
    );
  }

  Future<void> limparHistoricoTreinos() async {
    await _database.transaction(() async {
      await _database.delete(_database.planosTreinoExecucoes).go();
      await _database.delete(_database.seriesRealizadas).go();
      await _database.delete(_database.exerciciosRealizados).go();
      await _database.delete(_database.treinosRealizados).go();
    });
  }

  Future<int> _contarTabela(TableInfo<Table, dynamic> tabela) async {
    final quantidade = countAll();
    final consulta = _database.selectOnly(tabela)..addColumns([quantidade]);

    final linha = await consulta.getSingle();
    return linha.read(quantidade) ?? 0;
  }
}
