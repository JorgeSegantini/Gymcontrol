import 'package:flutter/material.dart';

import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../data/home_dashboard_models.dart';
import '../data/home_dashboard_service.dart';
import 'widgets/home_cabecalho_data.dart';
import 'widgets/home_plano_hoje.dart';
import 'widgets/home_timeline.dart';
import 'widgets/home_resumo_semanal.dart';
import 'widgets/home_calendario.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../perfil/data/perfil_local_controller.dart';
import '../../configuracoes/presentation/configuracoes_page.dart';
import '../../exercicios/presentation/exercicios_page.dart';
import '../../ficha_treino/presentation/fichas_treino_page.dart';
import '../../treino/presentation/treino_execucao_page.dart';
import '../../grupos_musculares/presentation/grupos_musculares_page.dart';
import '../../plano_treino/presentation/planos_treino_page.dart';
import '../../historico/presentation/historico_treinos_page.dart';
import '../../evolucao/presentation/evolucao_page.dart';
import '../../evolucao_corporal/presentation/evolucao_corporal_page.dart';
import '../../backup/presentation/backup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.database,
    required this.themeController,
    required this.perfilController,
    super.key,
  });

  final AppDatabase database;
  final ThemeController themeController;
  final PerfilLocalController perfilController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  HomeDashboardModel? _resumo;
  bool _carregandoDashboard = true;

  AppDatabase get database => widget.database;
  ThemeController get themeController => widget.themeController;
  PerfilLocalController get perfilController => widget.perfilController;

  HomeDashboardService get _dashboardService => HomeDashboardService(database);

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    final agora = DateTime.now();
    final mesAtual = DateTime(agora.year, agora.month);
    final primeiraCarga = _resumo == null;

    if (primeiraCarga && mounted) {
      setState(() {
        _carregandoDashboard = true;
      });
    }

    try {
      final resumo = await _dashboardService.obterResumo(
        mesCalendario: mesAtual,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resumo = resumo;
        _carregandoDashboard = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregandoDashboard = false;
      });
    }
  }

  Future<void> _abrirCalendario(BuildContext context) async {
    var mesSelecionado = DateTime(DateTime.now().year, DateTime.now().month);
    var resumoFuture = _dashboardService.obterResumo(
      mesCalendario: mesSelecionado,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void carregarMes(int deslocamento) {
              mesSelecionado = DateTime(
                mesSelecionado.year,
                mesSelecionado.month + deslocamento,
              );

              setSheetState(() {
                resumoFuture = _dashboardService.obterResumo(
                  mesCalendario: mesSelecionado,
                );
              });
            }

            void voltarHoje() {
              final agora = DateTime.now();
              mesSelecionado = DateTime(agora.year, agora.month);

              setSheetState(() {
                resumoFuture = _dashboardService.obterResumo(
                  mesCalendario: mesSelecionado,
                );
              });
            }

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.82,
                child: FutureBuilder<HomeDashboardModel>(
                  future: resumoFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Não foi possível carregar o calendário.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    }

                    final resumo = snapshot.data!;
                    final agora = DateTime.now();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: HomeCalendario(
                        calendario: resumo.calendario,
                        podeVoltarAoMesAtual:
                            mesSelecionado.year != agora.year ||
                            mesSelecionado.month != agora.month,
                        onMesAnterior: () {
                          carregarMes(-1);
                        },
                        onProximoMes: () {
                          carregarMes(1);
                        },
                        onVoltarAoMesAtual: voltarHoje,
                        onDiaTap: (dia) {
                          _mostrarDetalheDia(sheetContext, dia);
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      _carregarDashboard();
    }
  }

  Future<void> _continuarTreino(
    BuildContext context,
    TreinoRealizado treino,
  ) async {
    final treinoConcluido = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) {
          return TreinoExecucaoPage(
            database: database,
            treinoRealizadoId: treino.id,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (treinoConcluido == true) {
      final itemAtual = _resumo?.estadoPlano?.itemAtual;

      if (itemAtual != null &&
          itemAtual.tipo == TipoPlanoTreinoItem.treino.name &&
          itemAtual.fichaTreinoId == treino.fichaTreinoOrigemId) {
        await database.planoTreinoDao.registrarTreino(
          planoTreinoItemId: itemAtual.id,
          treinoRealizadoId: treino.id,
        );
      }
    }

    if (mounted) {
      _carregarDashboard();
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
        _carregarDashboard();
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

      _carregarDashboard();
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
      _carregarDashboard();
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
      _carregarDashboard();
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
      _carregarDashboard();
    }
  }

  Future<void> _abrirEvolucaoCorporal(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return EvolucaoCorporalPage(database: database);
        },
      ),
    );
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
      _carregarDashboard();
    }
  }

  Future<void> _abrirConfiguracoes(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ConfiguracoesPage(
            themeController: themeController,
            perfilController: perfilController,
          );
        },
      ),
    );

    if (mounted) {
      await perfilController.carregar();
    }
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
      body: _construirCorpo(context),
    );
  }

  Widget _construirCorpo(BuildContext context) {
    if (_carregandoDashboard && _resumo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_resumo == null) {
      return HomePlanoErroCard(
        onAbrirPlanos: () {
          _abrirPlanosTreino(context);
        },
      );
    }

    final resumo = _resumo!;

    return ListView(
      key: const PageStorageKey<String>('home-scroll'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        AnimatedBuilder(
          animation: perfilController,
          builder: (context, _) {
            return HomeCabecalhoData(
              data: DateTime.now(),
              nome: perfilController.nome ?? '',
            );
          },
        ),
        const SizedBox(height: 16),
        _ResumoPlanoAtivo(
          resumo: resumo,
          onCalendarioTap: () {
            _abrirCalendario(context);
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<TreinoRealizado?>(
          stream: database.treinoRealizadoDao.observarTreinoEmAndamento(),
          builder: (context, treinoSnapshot) {
            final treinoEmAndamento = treinoSnapshot.data;

            if (treinoEmAndamento != null) {
              return _TreinoEmAndamentoCard(
                treino: treinoEmAndamento,
                onContinuar: () {
                  _continuarTreino(context, treinoEmAndamento);
                },
              );
            }

            if (resumo.estadoPlano == null ||
                resumo.estadoPlano!.itemAtual == null) {
              return HomeSemPlanoAtivoCard(
                onAbrirPlanos: () {
                  _abrirPlanosTreino(context);
                },
                onEscolherFicha: () {
                  _abrirFichas(context);
                },
              );
            }

            return HomePlanoHojeCard(
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
            );
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

                if (itemAtual.tipo == TipoPlanoTreinoItem.treino.name) {
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

        const SizedBox(height: AppSpacing.lg),
        const _TituloSecao(
          titulo: 'Treinos',
          subtitulo: 'Monte e organize sua rotina',
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuGrid(
          itens: [
            _MenuItem(
              icon: Icons.assignment_outlined,
              titulo: 'Fichas de treino',
              onTap: () {
                _abrirFichas(context);
              },
            ),
            _MenuItem(
              icon: Icons.route_outlined,
              titulo: 'Planos de treino',
              onTap: () {
                _abrirPlanosTreino(context);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _TituloSecao(
          titulo: 'Cadastros',
          subtitulo: 'Biblioteca e organização dos exercícios',
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuGrid(
          itens: [
            _MenuItem(
              icon: Icons.sports_gymnastics_outlined,
              titulo: 'Exercícios',
              onTap: () {
                _abrirExercicios(context);
              },
            ),
            _MenuItem(
              icon: Icons.fitness_center_outlined,
              titulo: 'Grupos musculares',
              onTap: () {
                _abrirGruposMusculares(context);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _TituloSecao(
          titulo: 'Acompanhamento',
          subtitulo: 'Veja sua evolução ao longo do tempo',
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuGrid(
          itens: [
            _MenuItem(
              icon: Icons.history,
              titulo: 'Histórico',
              onTap: () {
                _abrirHistorico(context);
              },
            ),
            _MenuItem(
              icon: Icons.trending_up_outlined,
              titulo: 'Evolução',
              onTap: () {
                _abrirEvolucao(context);
              },
            ),
            _MenuItem(
              icon: Icons.monitor_weight_outlined,
              titulo: 'Evolução corporal',
              onTap: () {
                _abrirEvolucaoCorporal(context);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _TituloSecao(
          titulo: 'Sistema',
          subtitulo: 'Preferências e segurança dos dados',
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuGrid(
          itens: [
            _MenuItem(
              icon: Icons.settings_outlined,
              titulo: 'Configurações',
              onTap: () {
                _abrirConfiguracoes(context);
              },
            ),
            _MenuItem(
              icon: Icons.backup_outlined,
              titulo: 'Backup',
              onTap: () {
                _abrirBackup(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TreinoEmAndamentoCard extends StatelessWidget {
  const _TreinoEmAndamentoCard({
    required this.treino,
    required this.onContinuar,
  });

  final TreinoRealizado treino;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Treino em andamento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              treino.nomeFichaSnapshot,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Seu progresso está salvo. Continue de onde parou.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinuar,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continuar treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoPlanoAtivo extends StatelessWidget {
  const _ResumoPlanoAtivo({
    required this.resumo,
    required this.onCalendarioTap,
  });

  final HomeDashboardModel resumo;
  final VoidCallback onCalendarioTap;

  @override
  Widget build(BuildContext context) {
    final plano = resumo.estadoPlano?.plano;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              plano == null
                  ? 'Nenhum plano ativo'
                  : 'Plano ativo • ${plano.nome}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Abrir calendário',
            onPressed: onCalendarioTap,
            icon: const Icon(Icons.calendar_month_outlined),
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

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.titulo,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final VoidCallback onTap;
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.itens});

  final List<_MenuItem> itens;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const espacamento = AppSpacing.sm;
        final largura = (constraints.maxWidth - espacamento) / 2;

        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: [
            for (final item in itens)
              SizedBox(
                width: largura,
                child: _MenuTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 82),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: AppRadius.md,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        item.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
