import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'plano_treino_editor_page.dart';

class PlanosTreinoPage extends StatelessWidget {
  const PlanosTreinoPage({required this.database, super.key});

  final AppDatabase database;

  Future<void> _criarPlano(BuildContext context) async {
    final resultado = await showDialog<_NovoPlanoFormData>(
      context: context,
      builder: (_) {
        return const _NovoPlanoDialog();
      },
    );

    if (resultado == null || !context.mounted) {
      return;
    }

    try {
      await database.planoTreinoDao.criarPlano(
        nome: resultado.nome,
        objetivo: resultado.objetivo,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${resultado.nome} foi criado.')),
        );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(erro.message?.toString() ?? 'Dados inválidos.'),
          ),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível criar o plano de treino.'),
          ),
        );
    }
  }

  Future<void> _alterarSituacaoPlano(
    BuildContext context,
    PlanoTreino plano,
  ) async {
    try {
      final alterado = plano.situacao == SituacaoPlanoTreino.ativo.name
          ? await database.planoTreinoDao.pausarPlano(plano.id)
          : await database.planoTreinoDao.ativarPlano(plano.id);

      if (!context.mounted) {
        return;
      }

      if (!alterado) {
        throw StateError('O plano de treino não foi encontrado.');
      }

      final mensagem = plano.situacao == SituacaoPlanoTreino.ativo.name
          ? '${plano.nome} foi pausado.'
          : '${plano.nome} agora é o plano ativo.';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensagem)));
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
            content: Text('Não foi possível alterar o estado do plano.'),
          ),
        );
    }
  }

  Future<void> _excluirPlano(BuildContext context, PlanoTreino plano) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir plano'),
          content: Text(
            'Deseja excluir "${plano.nome}"? '
            'Todas as etapas deste plano também serão removidas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    try {
      final excluido = await database.planoTreinoDao.excluirPlano(plano.id);

      if (!context.mounted) {
        return;
      }

      if (!excluido) {
        throw StateError('O plano de treino não foi encontrado.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${plano.nome} foi excluído.')));
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
            content: Text('Não foi possível excluir o plano de treino.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planos de treino')),
      body: StreamBuilder<List<PlanoTreino>>(
        stream: database.planoTreinoDao.observarPlanos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar os planos de treino.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final planos = snapshot.data!;

          if (planos.isEmpty) {
            return const _EstadoVazio();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: planos.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              final plano = planos[index];

              return _PlanoCard(
                plano: plano,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) {
                        return PlanoTreinoEditorPage(
                          database: database,
                          plano: plano,
                        );
                      },
                    ),
                  );
                },
                onAlterarSituacao: () {
                  _alterarSituacaoPlano(context, plano);
                },
                onExcluir: () {
                  _excluirPlano(context, plano);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _criarPlano(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo plano'),
      ),
    );
  }
}

enum _AcaoPlano { alterarSituacao, excluir }

class _PlanoCard extends StatelessWidget {
  const _PlanoCard({
    required this.plano,
    required this.onTap,
    required this.onAlterarSituacao,
    required this.onExcluir,
  });

  final PlanoTreino plano;
  final VoidCallback onTap;
  final VoidCallback onAlterarSituacao;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final cor = Color(plano.corArgb);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cor,
          foregroundColor:
              ThemeData.estimateBrightnessForColor(cor) == Brightness.dark
              ? Colors.white
              : Colors.black,
          child: const Icon(Icons.route_outlined),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                plano.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (plano.situacao == SituacaoPlanoTreino.ativo.name)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Chip(
                  avatar: Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Ativo'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (plano.favorito)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.star_rounded, size: 20),
              ),
          ],
        ),
        subtitle: Text(
          [
            if (plano.objetivo != null && plano.objetivo!.trim().isNotEmpty)
              plano.objetivo!.trim(),
            _nomeSituacao(plano.situacao),
          ].join(' • '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<_AcaoPlano>(
              tooltip: 'Ações do plano',
              onSelected: (acao) {
                switch (acao) {
                  case _AcaoPlano.alterarSituacao:
                    onAlterarSituacao();
                  case _AcaoPlano.excluir:
                    onExcluir();
                }
              },
              itemBuilder: (context) {
                final ativo = plano.situacao == SituacaoPlanoTreino.ativo.name;

                return [
                  PopupMenuItem(
                    value: _AcaoPlano.alterarSituacao,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        ativo
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      title: Text(ativo ? 'Pausar plano' : 'Ativar plano'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: _AcaoPlano.excluir,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir plano'),
                    ),
                  ),
                ];
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  static String _nomeSituacao(String situacao) {
    return switch (situacao) {
      'ativo' => 'Ativo',
      'pausado' => 'Pausado',
      'encerrado' => 'Encerrado',
      _ => situacao,
    };
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum plano criado',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie um plano para organizar sua sequência de treinos, '
              'descansos e outras etapas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NovoPlanoFormData {
  const _NovoPlanoFormData({required this.nome, required this.objetivo});

  final String nome;
  final String? objetivo;
}

class _NovoPlanoDialog extends StatefulWidget {
  const _NovoPlanoDialog();

  @override
  State<_NovoPlanoDialog> createState() => _NovoPlanoDialogState();
}

class _NovoPlanoDialogState extends State<_NovoPlanoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _objetivoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final objetivo = _objetivoController.text.trim();

    Navigator.of(context).pop(
      _NovoPlanoFormData(
        nome: _nomeController.text.trim(),
        objetivo: objetivo.isEmpty ? null : objetivo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo plano de treino'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                autofocus: true,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Hipertrofia 2026',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome do plano.';
                  }

                  return null;
                },
                onFieldSubmitted: (_) {
                  _salvar();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _objetivoController,
                maxLength: 250,
                decoration: const InputDecoration(
                  labelText: 'Objetivo',
                  hintText: 'Ex.: Ganho de massa muscular',
                ),
                onFieldSubmitted: (_) {
                  _salvar();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Criar')),
      ],
    );
  }
}
