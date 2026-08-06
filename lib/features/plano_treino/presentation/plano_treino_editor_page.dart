import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'dialogs/plano_item_dialog.dart';

class PlanoTreinoEditorPage extends StatelessWidget {
  const PlanoTreinoEditorPage({
    required this.database,
    required this.plano,
    super.key,
  });

  final AppDatabase database;
  final PlanoTreino plano;

  Future<void> _adicionarEtapa(BuildContext context) async {
    final resultado = await showDialog<PlanoItemFormData>(
      context: context,
      builder: (_) {
        return PlanoItemDialog(database: database);
      },
    );

    if (resultado == null || !context.mounted) {
      return;
    }

    try {
      await database.planoTreinoDao.adicionarItem(
        planoTreinoId: plano.id,
        tipo: resultado.tipo,
        nome: resultado.nome,
        codigo: resultado.codigo,
        descricao: resultado.descricao,
        fichaTreinoId: resultado.fichaTreinoId,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${resultado.nome} foi adicionado ao plano.')),
        );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              erro.message?.toString() ?? 'Não foi possível adicionar a etapa.',
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
            content: Text('Não foi possível adicionar a etapa ao plano.'),
          ),
        );
    }
  }

  Future<void> _editarEtapa(BuildContext context, PlanoTreinoItem item) async {
    final resultado = await showDialog<PlanoItemFormData>(
      context: context,
      builder: (_) {
        return PlanoItemDialog(database: database, item: item);
      },
    );

    if (resultado == null || !context.mounted) {
      return;
    }

    try {
      final atualizado = await database.planoTreinoDao.editarItem(
        id: item.id,
        tipo: resultado.tipo,
        nome: resultado.nome,
        codigo: resultado.codigo,
        descricao: resultado.descricao,
        fichaTreinoId: resultado.fichaTreinoId,
        ativo: item.ativo,
      );

      if (!context.mounted) {
        return;
      }

      if (!atualizado) {
        throw StateError('A etapa não foi encontrada.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${resultado.nome} foi atualizado.')),
        );
    } on ArgumentError catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              erro.message?.toString() ?? 'Não foi possível editar a etapa.',
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
          const SnackBar(content: Text('Não foi possível editar a etapa.')),
        );
    }
  }

  Future<void> _removerEtapa(BuildContext context, PlanoTreinoItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover etapa'),
          content: Text('Deseja remover "${item.nome}" deste plano?'),
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
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    try {
      final removido = await database.planoTreinoDao.removerItem(item.id);

      if (!context.mounted) {
        return;
      }

      if (!removido) {
        throw StateError('A etapa não foi encontrada.');
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${item.nome} foi removido do plano.')),
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
          const SnackBar(content: Text('Não foi possível remover a etapa.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plano.nome)),
      body: StreamBuilder<List<PlanoTreinoItem>>(
        stream: database.planoTreinoDao.observarItens(plano.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as etapas deste plano.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final itens = snapshot.data!;

          return Column(
            children: [
              _CabecalhoPlano(plano: plano, quantidadeEtapas: itens.length),
              const Divider(height: 1),
              Expanded(
                child: itens.isEmpty
                    ? _EstadoVazio(
                        onAdicionar: () {
                          _adicionarEtapa(context);
                        },
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount: itens.length,
                        buildDefaultDragHandles: false,
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            elevation: 8,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: child,
                          );
                        },
                        onReorderItem: (oldIndex, newIndex) async {
                          if (oldIndex == newIndex) {
                            return;
                          }

                          final novaOrdem = [...itens];
                          final itemMovido = novaOrdem.removeAt(oldIndex);
                          novaOrdem.insert(newIndex, itemMovido);

                          try {
                            await database.planoTreinoDao.reordenarItens(
                              planoTreinoId: plano.id,
                              itensIds: [for (final item in novaOrdem) item.id],
                            );
                          } on ArgumentError catch (erro) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    erro.message?.toString() ??
                                        'Não foi possível reordenar as etapas.',
                                  ),
                                ),
                              );
                          } on StateError catch (erro) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(erro.message)),
                              );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Não foi possível reordenar as etapas.',
                                  ),
                                ),
                              );
                          }
                        },
                        itemBuilder: (context, index) {
                          final item = itens[index];

                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(item.id),
                            index: index,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: index < itens.length - 1 ? 10 : 0,
                              ),
                              child: _EtapaResumidaCard(
                                item: item,
                                onEditar: () {
                                  _editarEtapa(context, item);
                                },
                                onRemover: () {
                                  _removerEtapa(context, item);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _adicionarEtapa(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar etapa'),
      ),
    );
  }
}

class _CabecalhoPlano extends StatelessWidget {
  const _CabecalhoPlano({required this.plano, required this.quantidadeEtapas});

  final PlanoTreino plano;
  final int quantidadeEtapas;

  @override
  Widget build(BuildContext context) {
    final cor = Color(plano.corArgb);
    final descricao = plano.descricao?.trim();
    final objetivo = plano.objetivo?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        color: cor.withValues(alpha: 0.14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cor,
                foregroundColor:
                    ThemeData.estimateBrightnessForColor(cor) == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                child: const Icon(Icons.route_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plano.nome,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (objetivo != null && objetivo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        objetivo,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (descricao != null && descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Chip(
                      avatar: const Icon(Icons.format_list_numbered, size: 18),
                      label: Text(
                        quantidadeEtapas == 1
                            ? '1 etapa'
                            : '$quantidadeEtapas etapas',
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AcaoEtapa { editar, remover }

class _EtapaResumidaCard extends StatelessWidget {
  const _EtapaResumidaCard({
    required this.item,
    required this.onEditar,
    required this.onRemover,
  });

  final PlanoTreinoItem item;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.codigo?.trim().isNotEmpty == true
                ? item.codigo!.trim()
                : '${item.ordem + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(_iconeTipo(item.tipo), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        subtitle: item.descricao?.trim().isNotEmpty == true
            ? Text(
                item.descricao!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(_nomeTipo(item.tipo)),
        trailing: PopupMenuButton<_AcaoEtapa>(
          tooltip: 'Ações da etapa',
          onSelected: (acao) {
            switch (acao) {
              case _AcaoEtapa.editar:
                onEditar();
              case _AcaoEtapa.remover:
                onRemover();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: _AcaoEtapa.editar,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar etapa'),
                ),
              ),
              PopupMenuItem(
                value: _AcaoEtapa.remover,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Remover etapa'),
                ),
              ),
            ];
          },
        ),
        onTap: onEditar,
      ),
    );
  }

  static IconData _iconeTipo(String tipo) {
    return switch (tipo) {
      'treino' => Icons.fitness_center_outlined,
      'descanso' => Icons.bedtime_outlined,
      'cardio' => Icons.directions_run_outlined,
      'mobilidade' => Icons.self_improvement_outlined,
      'personalizado' => Icons.tune_outlined,
      _ => Icons.category_outlined,
    };
  }

  static String _nomeTipo(String tipo) {
    return switch (tipo) {
      'treino' => 'Treino',
      'descanso' => 'Descanso',
      'cardio' => 'Cardio',
      'mobilidade' => 'Mobilidade',
      'personalizado' => 'Personalizado',
      _ => tipo,
    };
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.onAdicionar});

  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 112),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_numbered_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma etapa cadastrada',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione treinos, descansos, cardio, mobilidade ou etapas '
              'personalizadas à sequência.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeira etapa'),
            ),
          ],
        ),
      ),
    );
  }
}
