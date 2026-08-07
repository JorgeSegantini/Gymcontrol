import 'package:drift/drift.dart';

import 'app_database.dart';

part 'peso_corporal_dao.g.dart';

@DriftAccessor(tables: [PesosCorporais])
class PesoCorporalDao extends DatabaseAccessor<AppDatabase>
    with _$PesoCorporalDaoMixin {
  PesoCorporalDao(super.database);

  Stream<List<PesoCorporal>> observarHistorico() {
    final consulta = select(pesosCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ]);

    return consulta.watch();
  }

  Future<List<PesoCorporal>> listarHistorico() {
    final consulta = select(pesosCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ]);

    return consulta.get();
  }

  Future<PesoCorporal?> obterPorId(int id) {
    return (select(
      pesosCorporais,
    )..where((registro) => registro.id.equals(id))).getSingleOrNull();
  }

  Future<PesoCorporal?> obterPorData(DateTime data) {
    final dataNormalizada = _normalizarData(data);

    return (select(pesosCorporais)
          ..where((registro) => registro.data.equals(dataNormalizada)))
        .getSingleOrNull();
  }

  Future<PesoCorporal?> obterMaisRecente() {
    final consulta = select(pesosCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ])
      ..limit(1);

    return consulta.getSingleOrNull();
  }

  Future<int> salvar({required DateTime data, required int pesoGramas}) async {
    if (pesoGramas <= 0) {
      throw ArgumentError.value(
        pesoGramas,
        'pesoGramas',
        'O peso deve ser maior que zero.',
      );
    }

    final dataNormalizada = _normalizarData(data);
    final existente = await obterPorData(dataNormalizada);

    if (existente == null) {
      return into(pesosCorporais).insert(
        PesosCorporaisCompanion.insert(
          data: dataNormalizada,
          pesoGramas: pesoGramas,
        ),
      );
    }

    await (update(
      pesosCorporais,
    )..where((registro) => registro.id.equals(existente.id))).write(
      PesosCorporaisCompanion(
        pesoGramas: Value(pesoGramas),
        atualizadoEm: Value(DateTime.now()),
      ),
    );

    return existente.id;
  }

  Future<int> editar({
    required int id,
    required DateTime data,
    required int pesoGramas,
  }) async {
    if (pesoGramas <= 0) {
      throw ArgumentError.value(
        pesoGramas,
        'pesoGramas',
        'O peso deve ser maior que zero.',
      );
    }

    final dataNormalizada = _normalizarData(data);
    final outroRegistroNaData = await obterPorData(dataNormalizada);

    if (outroRegistroNaData != null && outroRegistroNaData.id != id) {
      throw StateError('Já existe um registro de peso para esta data.');
    }

    return (update(
      pesosCorporais,
    )..where((registro) => registro.id.equals(id))).write(
      PesosCorporaisCompanion(
        data: Value(dataNormalizada),
        pesoGramas: Value(pesoGramas),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  Future<int> remover(int id) {
    return (delete(
      pesosCorporais,
    )..where((registro) => registro.id.equals(id))).go();
  }

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }
}
