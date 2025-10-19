import 'package:flutter/material.dart';
import '../models/treino_dto.dart';
import '../services/exercicio_service.dart';
import '../services/treino_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreinosPage extends StatefulWidget {
  final String grupoId;
  const TreinosPage({super.key, required this.grupoId});

  @override
  State<TreinosPage> createState() => _TreinosPageState();
}

class _TreinosPageState extends State<TreinosPage> {
  late Future<List<TreinoDTO>> treinosFuture;

  @override
  void initState() {
    super.initState();
    carregarTreinos();
  }

  void carregarTreinos() {
    treinosFuture = TreinoService().listarPorGrupo(widget.grupoId);
  }

  Widget _buildModalTextField(
      ThemeData theme, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(color: theme.colorScheme.onSurface),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          filled: true,
          fillColor: theme.colorScheme.background,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.onSurface),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> mostrarModalTreino({TreinoDTO? treinoExistente}) async {
    if (!mounted) return;
    final currentContext = context;

    final prefs = await SharedPreferences.getInstance();
    final alunoId = prefs.getString('aluno_id') ?? '';
    final exercicios = await ExercicioService().listar();
    if (!mounted) return;

    String? selectedExercicioId = treinoExistente?.exercicioId;
    final seriesController =
        TextEditingController(text: treinoExistente?.series.toString());
    final repMinController =
        TextEditingController(text: treinoExistente?.repMin.toString());
    final repMaxController =
        TextEditingController(text: treinoExistente?.repMax.toString());
    final pesoController =
        TextEditingController(text: treinoExistente?.pesoInicial.toString());
    final observacaoController =
        TextEditingController(text: treinoExistente?.observacao ?? '');

    await showDialog(
      context: currentContext,
      builder: (context) {
        final theme = Theme.of(currentContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            treinoExistente == null ? "Criar Treino" : "Editar Treino",
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedExercicioId,
                  items: exercicios.map((ex) {
                    return DropdownMenuItem(
                      value: ex.id,
                      child: Text(
                        ex.nome,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedExercicioId = value;
                    final exSelecionado =
                        exercicios.firstWhere((ex) => ex.id == value);
                    seriesController.text =
                        exSelecionado.series.toString();
                    repMinController.text =
                        exSelecionado.repMin.toString();
                    repMaxController.text =
                        exSelecionado.repMax.toString();
                    pesoController.text =
                        exSelecionado.pesoInicial.toString();
                  },
                  decoration: InputDecoration(
                    labelText: 'Exercício',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                    filled: true,
                    fillColor: theme.colorScheme.background,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: theme.colorScheme.onSurface),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: theme.colorScheme.surface,
                ),
                const SizedBox(height: 8),
                _buildModalTextField(theme, seriesController, "Séries"),
                _buildModalTextField(theme, repMinController, "Reps mínimas"),
                _buildModalTextField(theme, repMaxController, "Reps máximas"),
                _buildModalTextField(theme, pesoController, "Peso inicial (kg)"),
                _buildModalTextField(theme, observacaoController, "Observação"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(currentContext),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (selectedExercicioId == null || selectedExercicioId!.isEmpty) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text("Selecione um exercício")),
                  );
                  return;
                }

                final exSelecionado =
                    exercicios.firstWhere((ex) => ex.id == selectedExercicioId);

                final treino = TreinoDTO(
                  id: treinoExistente?.id,
                  grupoId: widget.grupoId,
                  alunoId: alunoId,
                  exercicioId: selectedExercicioId!,
                  nomeExercicio: exSelecionado.nome,
                  series: int.tryParse(seriesController.text) ?? exSelecionado.series,
                  repMin: int.tryParse(repMinController.text) ?? exSelecionado.repMin,
                  repMax: int.tryParse(repMaxController.text) ?? exSelecionado.repMax,
                  pesoInicial: double.tryParse(pesoController.text) ?? exSelecionado.pesoInicial,
                  diaDaSemana: treinoExistente?.diaDaSemana ?? 'Segunda-feira',
                  ordem: treinoExistente?.ordem ?? 1,
                  observacao: observacaoController.text,
                );

                try {
                  if (treinoExistente == null) {
                    await TreinoService().adicionarTreino(treino);
                  } else {
                    await TreinoService().editarTreino(treino);
                  }

                  if (!mounted) return;
                  Navigator.pop(currentContext, true);
                  setState(() => carregarTreinos());
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        treinoExistente == null
                            ? "Treino criado com sucesso"
                            : "Treino atualizado com sucesso",
                      ),
                      backgroundColor: Colors.greenAccent,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao salvar treino: $e"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> excluirTreino(String treinoId) async {
    try {
      await TreinoService().excluirTreino(treinoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Treino excluído com sucesso"),
          backgroundColor: Colors.greenAccent,
        ),
      );
      setState(() => carregarTreinos());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao excluir treino: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treinos do Grupo")),
      floatingActionButton: FloatingActionButton(
        tooltip: "Adicionar treino",
        child: const Icon(Icons.add),
        onPressed: () => mostrarModalTreino(),
      ),
      body: FutureBuilder<List<TreinoDTO>>(
        future: treinosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum treino encontrado'));
          }

          final treinos = snapshot.data!;
          return ListView.builder(
            itemCount: treinos.length,
            itemBuilder: (context, index) {
              final treino = treinos[index];
              return Card(
                child: ListTile(
                  title: Text(
                    treino.nomeExercicio,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Séries: ${treino.series} • Reps: ${treino.repMin}-${treino.repMax} • Peso inicial: ${treino.pesoInicial} kg",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => mostrarModalTreino(treinoExistente: treino),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Excluir treino"),
                              content: const Text(
                                  "Tem certeza que deseja excluir este treino?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Excluir"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && treino.id != null) {
                            await excluirTreino(treino.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
