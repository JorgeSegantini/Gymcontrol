import 'package:drift/drift.dart';

import 'app_database.dart';

part 'grupo_muscular_dao.g.dart';

@DriftAccessor(tables: [GruposMusculares])
class GrupoMuscularDao extends DatabaseAccessor<AppDatabase>
    with _$GrupoMuscularDaoMixin {
  GrupoMuscularDao(super.database);

  Stream<List<GrupoMuscular>> observarTodos({bool incluirInativos = true}) {
    final consulta = select(gruposMusculares);

    if (!incluirInativos) {
      consulta.where((grupo) => grupo.ativo.equals(true));
    }

    consulta.orderBy([
      (grupo) => OrderingTerm.asc(grupo.ordem),
      (grupo) => OrderingTerm.asc(grupo.nome),
    ]);

    return consulta.watch();
  }

  Future<GrupoMuscular?> obterPorId(int id) {
    return (select(
      gruposMusculares,
    )..where((grupo) => grupo.id.equals(id))).getSingleOrNull();
  }

  Future<GrupoMuscular?> obterPorCodigoBiblioteca(String codigo) {
    return (select(gruposMusculares)..where(
          (grupo) => grupo.codigoBiblioteca.equals(codigo.trim().toLowerCase()),
        ))
        .getSingleOrNull();
  }

  Future<int> cadastrar({required String nome, int ordem = 0}) {
    return into(gruposMusculares).insert(
      GruposMuscularesCompanion.insert(
        nome: nome.trim(),
        origem: Value(OrigemGrupoMuscular.personalizado.name),
        codigoBiblioteca: const Value(null),
        ordem: Value(ordem),
      ),
    );
  }

  Future<int> editar({
    required int id,
    required String nome,
    required int ordem,
  }) {
    return (update(
      gruposMusculares,
    )..where((grupo) => grupo.id.equals(id))).write(
      GruposMuscularesCompanion(
        nome: Value(nome.trim()),
        ordem: Value(ordem),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  Future<int> alterarSituacao({required int id, required bool ativo}) {
    return (update(
      gruposMusculares,
    )..where((grupo) => grupo.id.equals(id))).write(
      GruposMuscularesCompanion(
        ativo: Value(ativo),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }
}
