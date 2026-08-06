import '../../../core/database/app_database.dart';
import '../../../core/database/plano_treino_dao.dart';
import '../../../core/database/treino_tables.dart';
import 'home_dashboard_models.dart';

class HomeDashboardService {
  HomeDashboardService(this._database);

  final AppDatabase _database;

  Future<HomeDashboardModel> obterResumo({
    DateTime? agora,
    DateTime? mesCalendario,
  }) async {
    final dataAtual = agora ?? DateTime.now();
    final mesSelecionado = mesCalendario == null
        ? DateTime(dataAtual.year, dataAtual.month)
        : DateTime(mesCalendario.year, mesCalendario.month);
    final estado = await _database.planoTreinoDao.obterEstadoAtual();
    final timeline = <HomeTimelineItem>[];
    var execucoes = <PlanoTreinoExecucao>[];

    if (estado != null) {
      execucoes = await _database.planoTreinoDao.listarExecucoesDoPlano(
        estado.plano.id,
      );

      final anteriores = execucoes.take(2).toList().reversed;

      for (final execucao in anteriores) {
        timeline.add(
          HomeTimelineItem(
            etapa: HomeTimelineEtapa.anterior,
            data: execucao.dataReferencia,
            titulo: execucao.nomeItemSnapshot,
            tipo: execucao.tipoItemSnapshot,
            codigo: execucao.codigoItemSnapshot,
          ),
        );
      }

      final atual = estado.itemAtual;

      if (atual != null) {
        timeline.add(
          HomeTimelineItem(
            etapa: HomeTimelineEtapa.atual,
            data: dataAtual,
            titulo: atual.nome,
            tipo: atual.tipo,
            codigo: atual.codigo,
            descricao: atual.descricao,
          ),
        );

        final itens = await _database.planoTreinoDao.listarItens(
          estado.plano.id,
        );
        final itensAtivos = itens.where((item) => item.ativo).toList();
        final indiceAtual = itensAtivos.indexWhere(
          (item) => item.id == atual.id,
        );

        if (indiceAtual >= 0 && itensAtivos.isNotEmpty) {
          for (var deslocamento = 1; deslocamento <= 2; deslocamento++) {
            final proxima =
                itensAtivos[(indiceAtual + deslocamento) % itensAtivos.length];

            timeline.add(
              HomeTimelineItem(
                etapa: HomeTimelineEtapa.proxima,
                data: DateTime(
                  dataAtual.year,
                  dataAtual.month,
                  dataAtual.day + deslocamento,
                ),
                titulo: proxima.nome,
                tipo: proxima.tipo,
                codigo: proxima.codigo,
                descricao: proxima.descricao,
              ),
            );
          }
        }
      }
    }

    return HomeDashboardModel(
      dataAtual: dataAtual,
      saudacao: _criarSaudacao(dataAtual.hour),
      estadoPlano: estado,
      timeline: timeline,
      calendario: _criarCalendario(
        dataAtual: dataAtual,
        mesSelecionado: mesSelecionado,
        estado: estado,
        execucoes: execucoes,
      ),
      resumoSemana: await _criarResumoSemana(
        dataAtual: dataAtual,
        execucoesPlano: execucoes,
      ),
    );
  }

  Future<HomeResumoSemana> _criarResumoSemana({
    required DateTime dataAtual,
    required List<PlanoTreinoExecucao> execucoesPlano,
  }) async {
    final hoje = DateTime(dataAtual.year, dataAtual.month, dataAtual.day);
    final inicioSemana = hoje.subtract(
      Duration(days: dataAtual.weekday - DateTime.monday),
    );
    final fimExclusivo = hoje.add(const Duration(days: 1));

    final treinos = await _database.treinoRealizadoDao
        .observarTreinos(incluirCancelados: false)
        .first;

    final treinosConcluidos = treinos.where((treino) {
      if (treino.situacao != SituacaoTreinoRealizado.concluido.name) {
        return false;
      }

      final data = treino.finalizadoEm ?? treino.iniciadoEm;

      return !data.isBefore(inicioSemana) && data.isBefore(fimExclusivo);
    }).toList();

    var duracaoTotal = Duration.zero;

    for (final treino in treinosConcluidos) {
      final finalizadoEm = treino.finalizadoEm;

      if (finalizadoEm == null || finalizadoEm.isBefore(treino.iniciadoEm)) {
        continue;
      }

      duracaoTotal += finalizadoEm.difference(treino.iniciadoEm);
    }

    final etapasConcluidas = execucoesPlano.where((execucao) {
      final data = execucao.dataReferencia;

      if (data.isBefore(inicioSemana) || !data.isBefore(fimExclusivo)) {
        return false;
      }

      return execucao.situacao == SituacaoPlanoTreinoExecucao.concluida.name ||
          execucao.situacao == SituacaoPlanoTreinoExecucao.substituida.name;
    }).length;

    return HomeResumoSemana(
      inicioSemana: inicioSemana,
      fimPeriodo: hoje,
      quantidadeTreinos: treinosConcluidos.length,
      duracaoTotal: duracaoTotal,
      etapasConcluidas: etapasConcluidas,
    );
  }

  static HomeCalendarioMes _criarCalendario({
    required DateTime dataAtual,
    required DateTime mesSelecionado,
    required EstadoPlanoAtual? estado,
    required List<PlanoTreinoExecucao> execucoes,
  }) {
    final primeiroDia = DateTime(mesSelecionado.year, mesSelecionado.month);
    final quantidadeDias = DateTime(
      mesSelecionado.year,
      mesSelecionado.month + 1,
      0,
    ).day;
    final execucaoPorData = <String, PlanoTreinoExecucao>{};

    for (final execucao in execucoes.reversed) {
      final data = execucao.dataReferencia;

      if (data.year != mesSelecionado.year ||
          data.month != mesSelecionado.month) {
        continue;
      }

      execucaoPorData[_chaveData(data)] = execucao;
    }

    final atual = estado?.itemAtual;
    final proxima = estado?.proximoItem;
    final amanha = DateTime(dataAtual.year, dataAtual.month, dataAtual.day + 1);

    final dias = <HomeCalendarioDia>[];

    for (var dia = 1; dia <= quantidadeDias; dia++) {
      final data = DateTime(primeiroDia.year, primeiroDia.month, dia);
      final execucao = execucaoPorData[_chaveData(data)];

      if (execucao != null) {
        dias.add(
          HomeCalendarioDia(
            data: data,
            situacao: HomeCalendarioSituacao.realizado,
            titulo: execucao.nomeItemSnapshot,
            tipo: execucao.tipoItemSnapshot,
            codigo: execucao.codigoItemSnapshot,
          ),
        );
        continue;
      }

      if (_mesmoMes(mesSelecionado, dataAtual) && _mesmoDia(data, dataAtual)) {
        dias.add(
          HomeCalendarioDia(
            data: data,
            situacao: HomeCalendarioSituacao.hoje,
            titulo: atual?.nome,
            tipo: atual?.tipo,
            codigo: atual?.codigo,
          ),
        );
        continue;
      }

      if (_mesmoMes(mesSelecionado, dataAtual) &&
          _mesmoDia(data, amanha) &&
          proxima != null) {
        dias.add(
          HomeCalendarioDia(
            data: data,
            situacao: HomeCalendarioSituacao.previsto,
            titulo: proxima.nome,
            tipo: proxima.tipo,
            codigo: proxima.codigo,
          ),
        );
        continue;
      }

      dias.add(
        HomeCalendarioDia(
          data: data,
          situacao: HomeCalendarioSituacao.semRegistro,
        ),
      );
    }

    return HomeCalendarioMes(
      ano: mesSelecionado.year,
      mes: mesSelecionado.month,
      dias: dias,
    );
  }

  static bool _mesmoMes(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _chaveData(DateTime data) {
    return '${data.year}-${data.month}-${data.day}';
  }

  static String _criarSaudacao(int hora) {
    if (hora < 12) {
      return 'Bom dia! 👋';
    }

    if (hora < 18) {
      return 'Boa tarde! 👋';
    }

    return 'Boa noite! 👋';
  }
}
