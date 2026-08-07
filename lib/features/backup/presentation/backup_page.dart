import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../data/backup_info.dart';
import '../data/backup_service.dart';
import '../data/backup_selecionado.dart';
import '../data/manutencao_banco_info.dart';
import '../data/manutencao_banco_service.dart';
import 'widgets/confirmar_limpeza_historico_dialog.dart';
import 'widgets/informacoes_banco_card.dart';
import 'widgets/backup_action_button.dart';
import 'widgets/backup_info_card.dart';
import 'widgets/backup_status_card.dart';
import 'widgets/backup_preview_card.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({required this.database, super.key});

  final AppDatabase database;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final BackupService _service;
  late final ManutencaoBancoService _manutencaoService;
  late Future<BackupInfo> _infoFuture;
  late Future<ManutencaoBancoInfo> _manutencaoInfoFuture;
  bool _limpandoHistorico = false;
  bool _criandoBackup = false;
  bool _selecionandoBackup = false;
  bool _restaurandoBackup = false;
  BackupSelecionado? _backupSelecionado;

  @override
  void initState() {
    super.initState();
    _service = BackupService(widget.database);
    _manutencaoService = ManutencaoBancoService(widget.database);
    _carregar();
  }

  void _carregar() {
    _infoFuture = _service.obterInformacoes();
    _manutencaoInfoFuture = _manutencaoService.obterInformacoes();
  }

  Future<void> _fazerBackup() async {
    if (_criandoBackup) {
      return;
    }

    setState(() {
      _criandoBackup = true;
    });

    BackupCriado? backup;

    try {
      backup = await _service.criarArquivoBackup();

      if (!mounted) {
        return;
      }

      setState(() {
        _criandoBackup = false;
        _carregar();
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Backup criado com sucesso: ${backup.nomeArquivo}'),
          ),
        );
    } on BackupException catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _criandoBackup = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.mensagem)));
      return;
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _criandoBackup = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível criar o backup: $erro')),
        );
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await _service.compartilharBackup(backup);

      if (mounted) {
        setState(_carregar);
      }
    } on BackupCompartilhamentoException catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'O backup foi criado, mas não foi possível compartilhá-lo: '
              '$erro',
            ),
          ),
        );
    }
  }

  Future<void> _selecionarBackup() async {
    if (_selecionandoBackup) {
      return;
    }

    setState(() {
      _selecionandoBackup = true;
    });

    try {
      final backup = await _service.selecionarEValidarBackup();

      if (!mounted) {
        return;
      }

      setState(() {
        _selecionandoBackup = false;
        _backupSelecionado = backup;
      });

      if (backup != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Backup validado com sucesso.')),
          );
      }
    } on BackupValidacaoException catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selecionandoBackup = false;
        _backupSelecionado = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selecionandoBackup = false;
        _backupSelecionado = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Não foi possível selecionar o backup: $erro'),
          ),
        );
    }
  }

  Future<void> _restaurarBackup() async {
    final backup = _backupSelecionado;

    if (backup == null || _restaurandoBackup) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.restore_outlined),
          title: const Text('Restaurar backup?'),
          content: Text(
            'Os dados atuais deste aparelho serão substituídos pelos dados de '
            '${backup.nomeArquivo}.\n\n'
            'Depois da restauração, o GymControl será fechado para que o banco '
            'restaurado seja carregado com segurança na próxima abertura.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _restaurandoBackup = true;
    });

    try {
      await _service.restaurarBackup(backup);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.check_circle_outline),
            title: const Text('Backup restaurado'),
            content: const Text(
              'A restauração foi concluída com sucesso. O GymControl será '
              'fechado agora. Abra o aplicativo novamente para usar os dados '
              'restaurados.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Fechar GymControl'),
              ),
            ],
          );
        },
      );

      await SystemNavigator.pop();
    } on BackupValidacaoException catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _restaurandoBackup = false;
        _backupSelecionado = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } on BackupRestauracaoException catch (erro) {
      if (!mounted) {
        return;
      }

      if (erro.exigeReinicio) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.error_outline),
              title: const Text('Restauração não concluída'),
              content: Text(
                '${erro.mensagem}\n\n'
                'Por segurança, o GymControl será fechado. Abra o aplicativo '
                'novamente antes de continuar usando.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Fechar GymControl'),
                ),
              ],
            );
          },
        );

        await SystemNavigator.pop();
        return;
      }

      setState(() {
        _restaurandoBackup = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _restaurandoBackup = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível restaurar o backup: $erro')),
        );
    }
  }

  Future<void> _limparHistorico() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const ConfirmarLimpezaHistoricoDialog();
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _limpandoHistorico = true;
    });

    try {
      await _manutencaoService.limparHistoricoTreinos();

      if (!mounted) {
        return;
      }

      setState(() {
        _limpandoHistorico = false;
        _carregar();
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Histórico de treinos limpo com sucesso.'),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _limpandoHistorico = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível limpar o histórico de treinos.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: FutureBuilder<BackupInfo>(
        future: _infoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _BackupErro(
              onTentarNovamente: () {
                setState(_carregar);
              },
            );
          }

          final info = snapshot.data ?? BackupInfo.vazio;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const BackupInfoCard(),
              const SizedBox(height: 16),
              BackupStatusCard(info: info),
              const SizedBox(height: 20),
              Text(
                'Ações',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              BackupActionButton(
                icon: Icons.archive_outlined,
                titulo: _criandoBackup ? 'Criando backup...' : 'Fazer backup',
                subtitulo: _criandoBackup
                    ? 'Gerando uma cópia consistente do banco'
                    : 'Criar e compartilhar um arquivo .gym',
                destaque: true,
                onPressed: _criandoBackup ? () {} : _fazerBackup,
              ),
              const SizedBox(height: 10),
              BackupActionButton(
                icon: Icons.unarchive_outlined,
                titulo: _selecionandoBackup
                    ? 'Selecionando arquivo...'
                    : 'Selecionar backup',
                subtitulo: 'Validar um arquivo .gym antes da restauração',
                onPressed: _selecionandoBackup ? () {} : _selecionarBackup,
              ),
              if (_backupSelecionado != null) ...[
                const SizedBox(height: 12),
                BackupPreviewCard(backup: _backupSelecionado!),
                const SizedBox(height: 10),
                BackupActionButton(
                  icon: Icons.restore_outlined,
                  titulo: _restaurandoBackup
                      ? 'Restaurando backup...'
                      : 'Restaurar este backup',
                  subtitulo: _restaurandoBackup
                      ? 'Substituindo o banco local com segurança'
                      : 'Substituir os dados atuais pelos dados validados',
                  destaque: true,
                  onPressed: _restaurandoBackup ? () {} : _restaurarBackup,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Manutenção',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              FutureBuilder<ManutencaoBancoInfo>(
                future: _manutencaoInfoFuture,
                builder: (context, manutencaoSnapshot) {
                  if (manutencaoSnapshot.hasError) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'Não foi possível carregar as informações do banco.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!manutencaoSnapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final manutencaoInfo = manutencaoSnapshot.data!;

                  return Column(
                    children: [
                      InformacoesBancoCard(info: manutencaoInfo),
                      const SizedBox(height: 10),
                      BackupActionButton(
                        icon: Icons.delete_sweep_outlined,
                        titulo: _limpandoHistorico
                            ? 'Limpando histórico...'
                            : 'Limpar histórico de treinos',
                        subtitulo: manutencaoInfo.possuiHistorico
                            ? 'Apagar treinos e séries, preservando fichas e planos'
                            : 'Não existem registros de treino para remover',
                        onPressed:
                            _limpandoHistorico ||
                                !manutencaoInfo.possuiHistorico
                            ? () {}
                            : _limparHistorico,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A limpeza remove o histórico, a evolução e o '
                          'progresso executado do plano. Fichas, planos, '
                          'exercícios, grupos musculares e configurações são '
                          'preservados.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackupErro extends StatelessWidget {
  const _BackupErro({required this.onTentarNovamente});

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
              'Não foi possível carregar as informações de backup.',
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
