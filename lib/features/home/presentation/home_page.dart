import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/home_dashboard_models.dart';
import '../data/home_dashboard_service.dart';
import 'widgets/home_cabecalho_data.dart';
import 'widgets/home_plano_hoje.dart';
import 'widgets/home_timeline.dart';
import 'widgets/home_resumo_semanal.dart';
import 'widgets/home_calendario.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../configuracoes/presentation/configuracoes_page.dart';
import '../../exercicios/presentation/exercicios_page.dart';
import '../../ficha_treino/presentation/fichas_treino_page.dart';
import '../../treino/presentation/treino_execucao_page.dart';
import '../../grupos_musculares/presentation/grupos_musculares_page.dart';
import '../../plano_treino/presentation/planos_treino_page.dart';
import '../../historico/presentation/historico_treinos_page.dart';
import '../../evolucao/presentation/evolucao_page.dart';
import '../../backup/presentation/backup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.database,
    required this.themeController,
    super.key,
  });

  final AppDatabase database;
  final ThemeController themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _mesCalendario;
  late Future<HomeDashboardModel> _resumoFuture;
  bool _calendarioVisivel = false;

  AppDatabase get database => widget.database;
  ThemeController get themeController => widget.themeController;

  HomeDashboardService get _dashboardService => HomeDashboardService(database);

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesCalendario = DateTime(agora.year, agora.month);
    _recarregarDashboard();
  }

  void _recarregarDashboard() {
    _resumoFuture = _dashboardService.obterResumo(
      mesCalendario: _mesCalendario,
    );
  }

  void _alterarMesCalendario(int deslocamento) {
    setState(() {
      _mesCalendario = DateTime(
        _mesCalendario.year,
        _mesCalendario.month + deslocamento,
      );
      _recarregarDashboard();
    });
  }

  void _alternarCalendario() {
    setState(() {
      _calendarioVisivel = !_calendarioVisivel;
    });
  }

  void _voltarMesAtual() {
    final agora = DateTime.now();

    setState(() {
      _mesCalendario = DateTime(agora.year, agora.month);
      _recarregarDashboard();
    });
  }

  Future<void> _abrirFichas(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return FichasTreinoPage(database: database);
        },
      ),
    );

    if (mounted) {
      setState(_recarregarDashboard);
    }
  }

  Future<void> _iniciarTreinoPlanejado(
    BuildContext context,
    PlanoTreinoItem item,
  ) async {
    final fichaTreinoId = item.fichaTreinoId;

    if (fichaTreinoId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Esta etapa não possui uma ficha vinculada.'),
          ),
        );
      return;
    }

    try {
      final treinoRealizadoId = await database.treinoRealizadoDao
          .iniciarTreinoDaFicha(fichaTreinoId: fichaTreinoId);

      if (!context.mounted) {
        return;
      }

      final treinoConcluido = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) {
            return TreinoExecucaoPage(
              database: database,
              treinoRealizadoId: treinoRealizadoId,
            );
          },
        ),
      );

      if (!mounted) {
        return;
      }

      if (treinoConcluido == true) {
        await database.planoTreinoDao.registrarTreino(
          planoTreinoItemId: item.id,
          treinoRealizadoId: treinoRealizadoId,
        );
      }

      if (mounted) {
        setState(_recarregarDashboard);
      }
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              erro.message?.toString() ?? 'Não foi possível iniciar o treino.',
            ),
          ),
        );
    } on StateError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.message)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível iniciar o treino planejado.'),
          ),
        );
    }
  }

  Future<void> _concluirEtapaSemTreino(
    BuildContext context,
    PlanoTreinoItem item,
  ) async {
    try {
      if (item.tipo == TipoPlanoTreinoItem.descanso.name) {
        await database.planoTreinoDao.registrarDescanso(
          planoTreinoItemId: item.id,
        );
      } else {
        await database.planoTreinoDao.registrarItemSemTreino(
          planoTreinoItemId: item.id,
        );
      }

      if (!context.mounted) {
        return;
      }

      final mensagem = item.tipo == TipoPlanoTreinoItem.descanso.name
          ? 'Descanso concluído.'
          : '${item.nome} concluído.';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensagem)));

      setState(_recarregarDashboard);
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              erro.message?.toString() ?? 'Não foi possível concluir a etapa.',
            ),
          ),
        );
    } on StateError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.message)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível concluir a etapa do plano.'),
          ),
        );
    }
  }

  void _mostrarDetalheDia(BuildContext context, HomeCalendarioDia dia) {
    final identificacao = dia.identificacao;
    final situacao = switch (dia.situacao) {
      HomeCalendarioSituacao.realizado => 'Realizado',
      HomeCalendarioSituacao.hoje => 'Hoje',
      HomeCalendarioSituacao.previsto => 'Previsto',
      HomeCalendarioSituacao.semRegistro => 'Sem registro',
    };

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dia.data.day.toString().padLeft(2, '0')}/'
                  '${dia.data.month.toString().padLeft(2, '0')}/'
                  '${dia.data.year}',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(situacao),
                if (identificacao != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    identificacao,
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _abrirExercicios(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ExerciciosPage(database: database);
        },
      ),
    );
  }

  void _abrirGruposMusculares(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return GruposMuscularesPage(database: database);
        },
      ),
    );
  }

  Future<void> _abrirPlanosTreino(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return PlanosTreinoPage(database: database);
        },
      ),
    );

    if (mounted) {
      setState(_recarregarDashboard);
    }
  }

  Future<void> _abrirHistorico(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return HistoricoTreinosPage(database: database);
        },
      ),
    );

    if (mounted) {
      setState(_recarregarDashboard);
    }
  }

  Future<void> _abrirEvolucao(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return EvolucaoPage(database: database);
        },
      ),
    );

    if (mounted) {
      setState(_recarregarDashboard);
    }
  }

  Future<void> _abrirBackup(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BackupPage(database: database);
        },
      ),
    );

    if (mounted) {
      setState(_recarregarDashboard);
    }
  }

  void _abrirConfiguracoes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ConfiguracoesPage(themeController: themeController);
        },
      ),
    );
  }

  void _mostrarEmDesenvolvimento(BuildContext context, String funcionalidade) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$funcionalidade em desenvolvimento.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymControl'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () {
              _abrirConfiguracoes(context);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          HomeCabecalhoData(data: DateTime.now()),
          const SizedBox(height: 16),
          FutureBuilder<HomeDashboardModel>(
            future: _resumoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return HomePlanoErroCard(
                  onAbrirPlanos: () {
                    _abrirPlanosTreino(context);
                  },
                );
              }

              final resumo = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ResumoPlanoAtivo(resumo: resumo),
                  const SizedBox(height: 12),
                  if (resumo.estadoPlano == null ||
                      resumo.estadoPlano!.itemAtual == null)
                    HomeSemPlanoAtivoCard(
                      onAbrirPlanos: () {
                        _abrirPlanosTreino(context);
                      },
                      onEscolherFicha: () {
                        _abrirFichas(context);
                      },
                    )
                  else
                    HomePlanoHojeCard(
                      estado: resumo.estadoPlano!,
                      onIniciarTreino: () {
                        _iniciarTreinoPlanejado(
                          context,
                          resumo.estadoPlano!.itemAtual!,
                        );
                      },
                      onConcluirEtapa: () {
                        _concluirEtapaSemTreino(
                          context,
                          resumo.estadoPlano!.itemAtual!,
                        );
                      },
                      onAbrirPlanos: () {
                        _abrirPlanosTreino(context);
                      },
                    ),
                  if (resumo.timeline.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    HomeTimeline(
                      itens: resumo.timeline,
                      onItemTap: (item) {
                        if (item.etapa == HomeTimelineEtapa.atual) {
                          final itemAtual = resumo.estadoPlano?.itemAtual;

                          if (itemAtual == null) {
                            return;
                          }

                          if (itemAtual.tipo ==
                              TipoPlanoTreinoItem.treino.name) {
                            _iniciarTreinoPlanejado(context, itemAtual);
                          } else {
                            _concluirEtapaSemTreino(context, itemAtual);
                          }

                          return;
                        }

                        _abrirPlanosTreino(context);
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  HomeResumoSemanal(resumo: resumo.resumoSemana),
                  const SizedBox(height: 16),
                  _AcessoCalendarioCard(
                    visivel: _calendarioVisivel,
                    mes: resumo.calendario.mes,
                    ano: resumo.calendario.ano,
                    onTap: _alternarCalendario,
                  ),
                  if (_calendarioVisivel) ...[
                    const SizedBox(height: 10),
                    HomeCalendario(
                      calendario: resumo.calendario,
                      podeVoltarAoMesAtual:
                          _mesCalendario.year != DateTime.now().year ||
                          _mesCalendario.month != DateTime.now().month,
                      onMesAnterior: () {
                        _alterarMesCalendario(-1);
                      },
                      onProximoMes: () {
                        _alterarMesCalendario(1);
                      },
                      onVoltarAoMesAtual: _voltarMesAtual,
                      onDiaTap: (dia) {
                        _mostrarDetalheDia(context, dia);
                      },
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const _TituloSecao(
            titulo: 'Treinos',
            subtitulo: 'Monte e organize sua rotina',
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.assignment_outlined,
            titulo: 'Fichas de treino',
            subtitulo: 'Criar, editar e organizar exercícios',
            onTap: () {
              _abrirFichas(context);
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.route_outlined,
            titulo: 'Planos de treino',
            subtitulo: 'Organizar a sequência A, B, descanso e outras etapas',
            onTap: () {
              _abrirPlanosTreino(context);
            },
          ),
          const SizedBox(height: 24),
          const _TituloSecao(
            titulo: 'Cadastros',
            subtitulo: 'Biblioteca e organização dos exercícios',
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.sports_gymnastics_outlined,
            titulo: 'Exercícios',
            subtitulo: 'Consultar e cadastrar exercícios',
            onTap: () {
              _abrirExercicios(context);
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.fitness_center_outlined,
            titulo: 'Grupos musculares',
            subtitulo: 'Organizar os exercícios por grupo',
            onTap: () {
              _abrirGruposMusculares(context);
            },
          ),
          const SizedBox(height: 24),
          const _TituloSecao(
            titulo: 'Acompanhamento',
            subtitulo: 'Veja sua evolução ao longo do tempo',
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.history,
            titulo: 'Histórico',
            subtitulo: 'Revise todos os treinos realizados',
            onTap: () {
              _abrirHistorico(context);
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.trending_up_outlined,
            titulo: 'Evolução',
            subtitulo: 'Acompanhe seu progresso por exercício',
            onTap: () {
              _abrirEvolucao(context);
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.monitor_weight_outlined,
            titulo: 'Peso corporal',
            subtitulo: 'Registre e acompanhe seu peso corporal',
            onTap: () {
              _mostrarEmDesenvolvimento(context, 'Peso corporal');
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.straighten_outlined,
            titulo: 'Medidas corporais',
            subtitulo: 'Compare sua evolução corporal ao longo do tempo',
            onTap: () {
              _mostrarEmDesenvolvimento(context, 'Medidas corporais');
            },
          ),
          const SizedBox(height: 24),
          const _TituloSecao(
            titulo: 'Sistema',
            subtitulo: 'Preferências e segurança dos dados',
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.settings_outlined,
            titulo: 'Configurações',
            subtitulo: 'Personalize tema, unidades e comportamento',
            onTap: () {
              _abrirConfiguracoes(context);
            },
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: Icons.backup_outlined,
            titulo: 'Backup',
            subtitulo: 'Proteja e restaure seus dados localmente',
            onTap: () {
              _abrirBackup(context);
            },
          ),
        ],
      ),
    );
  }
}

class _AcessoCalendarioCard extends StatelessWidget {
  const _AcessoCalendarioCard({
    required this.visivel,
    required this.mes,
    required this.ano,
    required this.onTap,
  });

  final bool visivel;
  final int mes;
  final int ano;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: const Text(
          'Calendário',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${_nomeMes(mes)} de $ano'),
        trailing: Icon(visivel ? Icons.expand_less : Icons.expand_more),
        onTap: onTap,
      ),
    );
  }

  static String _nomeMes(int mes) {
    return switch (mes) {
      DateTime.january => 'Janeiro',
      DateTime.february => 'Fevereiro',
      DateTime.march => 'Março',
      DateTime.april => 'Abril',
      DateTime.may => 'Maio',
      DateTime.june => 'Junho',
      DateTime.july => 'Julho',
      DateTime.august => 'Agosto',
      DateTime.september => 'Setembro',
      DateTime.october => 'Outubro',
      DateTime.november => 'Novembro',
      DateTime.december => 'Dezembro',
      _ => '',
    };
  }
}

class _ResumoPlanoAtivo extends StatelessWidget {
  const _ResumoPlanoAtivo({required this.resumo});

  final HomeDashboardModel resumo;

  @override
  Widget build(BuildContext context) {
    final plano = resumo.estadoPlano?.plano;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resumo.saudacao,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  plano == null
                      ? 'Nenhum plano ativo'
                      : 'Plano ativo • ${plano.nome}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (plano != null)
            Icon(
              Icons.route_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao({required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
