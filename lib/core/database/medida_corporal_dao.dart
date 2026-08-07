import 'package:drift/drift.dart';

import 'app_database.dart';

part 'medida_corporal_dao.g.dart';

@DriftAccessor(tables: [MedidasCorporais])
class MedidaCorporalDao extends DatabaseAccessor<AppDatabase>
    with _$MedidaCorporalDaoMixin {
  MedidaCorporalDao(super.database);

  Stream<List<MedidaCorporal>> observarHistorico() {
    final consulta = select(medidasCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ]);

    return consulta.watch();
  }

  Future<List<MedidaCorporal>> listarHistorico() {
    final consulta = select(medidasCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ]);

    return consulta.get();
  }

  Future<MedidaCorporal?> obterPorId(int id) {
    return (select(
      medidasCorporais,
    )..where((registro) => registro.id.equals(id))).getSingleOrNull();
  }

  Future<MedidaCorporal?> obterPorData(DateTime data) {
    final dataNormalizada = _normalizarData(data);

    return (select(medidasCorporais)
          ..where((registro) => registro.data.equals(dataNormalizada)))
        .getSingleOrNull();
  }

  Future<MedidaCorporal?> obterMaisRecente() {
    final consulta = select(medidasCorporais)
      ..orderBy([
        (registro) => OrderingTerm.desc(registro.data),
        (registro) => OrderingTerm.desc(registro.id),
      ])
      ..limit(1);

    return consulta.getSingleOrNull();
  }

  Future<int> salvar({
    required DateTime data,
    int? pescocoMilimetros,
    int? ombrosMilimetros,
    int? peitoMilimetros,
    int? cinturaMilimetros,
    int? abdomenMilimetros,
    int? quadrilMilimetros,
    int? bracoDireitoMilimetros,
    int? bracoEsquerdoMilimetros,
    int? coxaDireitaMilimetros,
    int? coxaEsquerdaMilimetros,
    int? panturrilhaDireitaMilimetros,
    int? panturrilhaEsquerdaMilimetros,
    String? observacoes,
  }) async {
    _validarMedidas([
      pescocoMilimetros,
      ombrosMilimetros,
      peitoMilimetros,
      cinturaMilimetros,
      abdomenMilimetros,
      quadrilMilimetros,
      bracoDireitoMilimetros,
      bracoEsquerdoMilimetros,
      coxaDireitaMilimetros,
      coxaEsquerdaMilimetros,
      panturrilhaDireitaMilimetros,
      panturrilhaEsquerdaMilimetros,
    ]);

    final dataNormalizada = _normalizarData(data);
    final existente = await obterPorData(dataNormalizada);
    final observacoesNormalizadas = _normalizarObservacoes(observacoes);

    final valores = MedidasCorporaisCompanion(
      data: Value(dataNormalizada),
      pescocoMilimetros: Value(pescocoMilimetros),
      ombrosMilimetros: Value(ombrosMilimetros),
      peitoMilimetros: Value(peitoMilimetros),
      cinturaMilimetros: Value(cinturaMilimetros),
      abdomenMilimetros: Value(abdomenMilimetros),
      quadrilMilimetros: Value(quadrilMilimetros),
      bracoDireitoMilimetros: Value(bracoDireitoMilimetros),
      bracoEsquerdoMilimetros: Value(bracoEsquerdoMilimetros),
      coxaDireitaMilimetros: Value(coxaDireitaMilimetros),
      coxaEsquerdaMilimetros: Value(coxaEsquerdaMilimetros),
      panturrilhaDireitaMilimetros: Value(panturrilhaDireitaMilimetros),
      panturrilhaEsquerdaMilimetros: Value(panturrilhaEsquerdaMilimetros),
      observacoes: Value(observacoesNormalizadas),
      atualizadoEm: Value(DateTime.now()),
    );

    if (existente == null) {
      return into(medidasCorporais).insert(valores);
    }

    await (update(
      medidasCorporais,
    )..where((registro) => registro.id.equals(existente.id))).write(valores);

    return existente.id;
  }

  Future<int> editar({
    required int id,
    required DateTime data,
    int? pescocoMilimetros,
    int? ombrosMilimetros,
    int? peitoMilimetros,
    int? cinturaMilimetros,
    int? abdomenMilimetros,
    int? quadrilMilimetros,
    int? bracoDireitoMilimetros,
    int? bracoEsquerdoMilimetros,
    int? coxaDireitaMilimetros,
    int? coxaEsquerdaMilimetros,
    int? panturrilhaDireitaMilimetros,
    int? panturrilhaEsquerdaMilimetros,
    String? observacoes,
  }) async {
    _validarMedidas([
      pescocoMilimetros,
      ombrosMilimetros,
      peitoMilimetros,
      cinturaMilimetros,
      abdomenMilimetros,
      quadrilMilimetros,
      bracoDireitoMilimetros,
      bracoEsquerdoMilimetros,
      coxaDireitaMilimetros,
      coxaEsquerdaMilimetros,
      panturrilhaDireitaMilimetros,
      panturrilhaEsquerdaMilimetros,
    ]);

    final dataNormalizada = _normalizarData(data);
    final outroRegistroNaData = await obterPorData(dataNormalizada);

    if (outroRegistroNaData != null && outroRegistroNaData.id != id) {
      throw StateError('Já existe um registro de medidas para esta data.');
    }

    return (update(
      medidasCorporais,
    )..where((registro) => registro.id.equals(id))).write(
      MedidasCorporaisCompanion(
        data: Value(dataNormalizada),
        pescocoMilimetros: Value(pescocoMilimetros),
        ombrosMilimetros: Value(ombrosMilimetros),
        peitoMilimetros: Value(peitoMilimetros),
        cinturaMilimetros: Value(cinturaMilimetros),
        abdomenMilimetros: Value(abdomenMilimetros),
        quadrilMilimetros: Value(quadrilMilimetros),
        bracoDireitoMilimetros: Value(bracoDireitoMilimetros),
        bracoEsquerdoMilimetros: Value(bracoEsquerdoMilimetros),
        coxaDireitaMilimetros: Value(coxaDireitaMilimetros),
        coxaEsquerdaMilimetros: Value(coxaEsquerdaMilimetros),
        panturrilhaDireitaMilimetros: Value(panturrilhaDireitaMilimetros),
        panturrilhaEsquerdaMilimetros: Value(panturrilhaEsquerdaMilimetros),
        observacoes: Value(_normalizarObservacoes(observacoes)),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  Future<int> remover(int id) {
    return (delete(
      medidasCorporais,
    )..where((registro) => registro.id.equals(id))).go();
  }

  void _validarMedidas(List<int?> medidas) {
    if (!medidas.any((medida) => medida != null)) {
      throw ArgumentError('Informe pelo menos uma medida corporal.');
    }

    for (final medida in medidas) {
      if (medida != null && medida <= 0) {
        throw ArgumentError.value(
          medida,
          'medidaMilimetros',
          'As medidas devem ser maiores que zero.',
        );
      }
    }
  }

  String? _normalizarObservacoes(String? observacoes) {
    final valor = observacoes?.trim();
    if (valor == null || valor.isEmpty) {
      return null;
    }
    return valor;
  }

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }
}
