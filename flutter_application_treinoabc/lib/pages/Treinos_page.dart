import 'package:flutter/material.dart';
import '../models/treino_dto.dart';
import '../models/exercicio_dto.dart';
import '../services/treino_service.dart';
import '../services/exercicio_service.dart';
import '../widgets/treino_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreinosPage extends StatefulWidget {
  final String grupoId;
  const TreinosPage({super.key, required this.grupoId});

  @override
  State<TreinosPage> createState() => _TreinosPageState();
}

class _TreinosPageState extends State<TreinosPage> {
  late Future<List<TreinoDTO>> treinosFuture;
  List<ExercicioDTO> exercicios = [];

  @override
  void initState() {
    super.initState();
    carregarExercicios();
    carregarTreinos();
  }

  void carregarTreinos() {
    treinosFuture = TreinoService().listarPorGrupo(widget.grupoId);
  }

  Future<void> carregarExercicios() async {
    final lista = await ExercicioService().listar();
    const ordemGrupos = [
      'Peito',
      'Costas',
      'Tríceps',
      'Bíceps',
      'Ombro',
      'Perna',
      'Abdômen',
      'Panturrilha',
    ];
    lista.sort((a, b) {
      final indexA = ordemGrupos.indexOf(a.grupoMuscular);
      final indexB = ordemGrupos.indexOf(b.grupoMuscular);
      return indexA.compareTo(indexB);
    });
    exercicios = lista;
  }

  Future<void> mostrarModalTreino({TreinoDTO? treinoExistente}) async {
    final prefs = await SharedPreferences.getInstance();
    final alunoId = prefs.getString('aluno_id') ?? '';

    final resultado = await showDialog(
      context: context,
      builder: (context) => TreinoModal(
        grupoId: widget.grupoId,
        alunoId: alunoId,
        exercicios: exercicios,
        treinoExistente: treinoExistente,
      ),
    );

    if (resultado == true) setState(() => carregarTreinos());
  }

  Future<void> excluirTreino(String treinoId) async {
    try {
      await TreinoService().excluirTreino(treinoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Treino excluído com sucesso"),
          backgroundColor: Colors.greenAccent,
        ),
      );
      setState(() => carregarTreinos());
    } catch (e) {
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
    const ordemGrupos = [
      'Peito',
      'Costas',
      'Tríceps',
      'Bíceps',
      'Ombro',
      'Perna',
      'Abdômen',
      'Panturrilha',
    ];

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
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Erro: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('Nenhum treino encontrado'));

          final treinos = snapshot.data!;
          // Ordena treinos pelo grupo muscular do exercício
          treinos.sort((a, b) {
            final exA = exercicios.firstWhere((ex) => ex.id == a.exercicioId);
            final exB = exercicios.firstWhere((ex) => ex.id == b.exercicioId);
            final indexA = ordemGrupos.indexOf(exA.grupoMuscular);
            final indexB = ordemGrupos.indexOf(exB.grupoMuscular);
            return indexA.compareTo(indexB);
          });

          return ListView.builder(
            itemCount: treinos.length,
            itemBuilder: (context, index) {
              final treino = treinos[index];
              exercicios.firstWhere((ex) => ex.id == treino.exercicioId);

              final valorStyle = TextStyle(
                color: Colors.purple[300],
                fontWeight: FontWeight.bold,
              );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha do título + botão de excluir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              treino.nomeExercicio,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Excluir treino"),
                                  content: const Text(
                                    "Tem certeza que deseja excluir este treino?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Excluir"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && treino.id != null)
                                await excluirTreino(treino.id!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Linha de séries, reps e peso (clicável para editar)
                      GestureDetector(
                        onTap: () =>
                            mostrarModalTreino(treinoExistente: treino),
                        child: Row(
                          children: [
                            Text('Séries: ', style: valorStyle),
                            Text(
                              '${treino.series}',
                            
                            ),
                            const SizedBox(width: 10),
                            Text('Reps: ', style: valorStyle),
                            Text(
                              '${treino.repMin}-${treino.repMax}',
                            
                            ),
                            const SizedBox(width: 10),
                            Text('Peso: ', style: valorStyle),
                            Text(
                              '${treino.pesoInicial} kg',
                            
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Observação
                      Text(
                        'Observação: ${treino.observacao}',
                        style: const TextStyle(color: Colors.grey),
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
