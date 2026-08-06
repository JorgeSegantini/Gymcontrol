import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/backup_info.dart';
import '../data/backup_service.dart';
import '../data/manutencao_banco_info.dart';
import '../data/manutencao_banco_service.dart';
import 'widgets/confirmar_limpeza_historico_dialog.dart';
import 'widgets/informacoes_banco_card.dart';
import 'widgets/backup_action_button.dart';
import 'widgets/backup_info_card.dart';
import 'widgets/backup_status_card.dart';

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

  void _restaurarBackup() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'A restauração de arquivos será adicionada na Etapa 15.2.',
          ),
        ),
      );
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
                titulo: 'Restaurar backup',
                subtitulo: 'Recuperar dados a partir de um arquivo GymControl',
                onPressed: _restaurarBackup,
              ),
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
