import 'package:flutter/material.dart';

import '../../../../core/biblioteca/services/biblioteca_pesquisa_service.dart';
import '../../../../core/database/app_database.dart';

class AdicionarExercicioBottomSheet extends StatefulWidget {
  const AdicionarExercicioBottomSheet({required this.database, super.key});

  final AppDatabase database;

  @override
  State<AdicionarExercicioBottomSheet> createState() =>
      _AdicionarExercicioBottomSheetState();
}

class _AdicionarExercicioBottomSheetState
    extends State<AdicionarExercicioBottomSheet> {
  final TextEditingController _pesquisaController = TextEditingController();
  final BibliotecaPesquisaService _pesquisaService =
      BibliotecaPesquisaService();

  int? _grupoMuscularId;

  AppDatabase get database => widget.database;

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(_atualizarPesquisa);
  }

  @override
  void dispose() {
    _pesquisaController
      ..removeListener(_atualizarPesquisa)
      ..dispose();

    super.dispose();
  }

  void _atualizarPesquisa() {
    setState(() {});
  }

  Future<List<Exercicio>> _pesquisar(
    List<Exercicio> exercicios,
    List<GrupoMuscular> grupos,
  ) {
    return _pesquisaService.pesquisar(
      exercicios: exercicios,
      grupos: grupos,
      termo: _pesquisaController.text,
      grupoMuscularId: _grupoMuscularId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alturaTela = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: SizedBox(
        height: alturaTela * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.fitness_center),
                  SizedBox(width: 8),
                  Text(
                    'Adicionar exercício',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _pesquisaController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Pesquisar exercício',
                  hintText: 'Nome, alias, grupo, equipamento, tag ou código',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _pesquisaController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar pesquisa',
                          onPressed: _pesquisaController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<GrupoMuscular>>(
              stream: database.grupoMuscularDao.observarTodos(
                incluirInativos: false,
              ),
              builder: (context, gruposSnapshot) {
                if (gruposSnapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Não foi possível carregar os grupos musculares.',
                    ),
                  );
                }

                if (!gruposSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  );
                }

                final grupos = gruposSnapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey(_grupoMuscularId),
                    initialValue: _grupoMuscularId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Grupo muscular',
                      prefixIcon: Icon(Icons.filter_alt_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos os grupos'),
                      ),
                      ...grupos.map(
                        (grupo) => DropdownMenuItem<int?>(
                          value: grupo.id,
                          child: Text(grupo.nome),
                        ),
                      ),
                    ],
                    onChanged: (valor) {
                      setState(() {
                        _grupoMuscularId = valor;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<GrupoMuscular>>(
                stream: database.grupoMuscularDao.observarTodos(
                  incluirInativos: false,
                ),
                builder: (context, gruposSnapshot) {
                  if (gruposSnapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Não foi possível carregar os grupos musculares.',
                      ),
                    );
                  }

                  if (!gruposSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final grupos = gruposSnapshot.data!;

                  return StreamBuilder<List<Exercicio>>(
                    stream: database.exercicioDao.observarAtivos(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Não foi possível carregar os exercícios.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return FutureBuilder<List<Exercicio>>(
                        future: _pesquisar(snapshot.data!, grupos),
                        builder: (context, pesquisaSnapshot) {
                          if (pesquisaSnapshot.hasError) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Não foi possível pesquisar os exercícios.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          if (!pesquisaSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final exercicios = pesquisaSnapshot.data!;

                          if (exercicios.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Nenhum exercício encontrado para os '
                                  'filtros selecionados.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: exercicios.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final exercicio = exercicios[index];
                              final familia = exercicio.familia?.trim();

                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.fitness_center),
                                ),
                                title: Text(exercicio.nome),
                                subtitle: familia == null || familia.isEmpty
                                    ? null
                                    : Text(familia),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pop(exercicio);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
