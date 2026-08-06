import '../../../core/database/plano_treino_dao.dart';

enum HomeTimelineEtapa { anterior, atual, proxima }

enum HomeCalendarioSituacao { semRegistro, realizado, hoje, previsto }

class HomeDashboardModel {
  const HomeDashboardModel({
    required this.dataAtual,
    required this.saudacao,
    required this.estadoPlano,
    required this.timeline,
    required this.calendario,
    required this.resumoSemana,
  });

  final DateTime dataAtual;
  final String saudacao;
  final EstadoPlanoAtual? estadoPlano;
  final List<HomeTimelineItem> timeline;
  final HomeCalendarioMes calendario;
  final HomeResumoSemana resumoSemana;
}

class HomeTimelineItem {
  const HomeTimelineItem({
    required this.etapa,
    required this.data,
    required this.titulo,
    required this.tipo,
    this.codigo,
    this.descricao,
  });

  final HomeTimelineEtapa etapa;
  final DateTime data;
  final String titulo;
  final String tipo;
  final String? codigo;
  final String? descricao;

  String get identificacao {
    final codigoTratado = codigo?.trim();

    if (codigoTratado == null || codigoTratado.isEmpty) {
      return titulo;
    }

    return '$codigoTratado • $titulo';
  }
}

class HomeCalendarioMes {
  const HomeCalendarioMes({
    required this.ano,
    required this.mes,
    required this.dias,
  });

  final int ano;
  final int mes;
  final List<HomeCalendarioDia> dias;
}

class HomeCalendarioDia {
  const HomeCalendarioDia({
    required this.data,
    required this.situacao,
    this.titulo,
    this.tipo,
    this.codigo,
  });

  final DateTime data;
  final HomeCalendarioSituacao situacao;
  final String? titulo;
  final String? tipo;
  final String? codigo;

  String? get identificacao {
    final tituloTratado = titulo?.trim();

    if (tituloTratado == null || tituloTratado.isEmpty) {
      return null;
    }

    final codigoTratado = codigo?.trim();

    if (codigoTratado == null || codigoTratado.isEmpty) {
      return tituloTratado;
    }

    return '$codigoTratado • $tituloTratado';
  }
}

class HomeResumoSemana {
  const HomeResumoSemana({
    required this.inicioSemana,
    required this.fimPeriodo,
    required this.quantidadeTreinos,
    required this.duracaoTotal,
    required this.etapasConcluidas,
  });

  final DateTime inicioSemana;
  final DateTime fimPeriodo;
  final int quantidadeTreinos;
  final Duration duracaoTotal;
  final int etapasConcluidas;
}
