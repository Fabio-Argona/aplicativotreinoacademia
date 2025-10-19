import 'package:flutter/material.dart';
import '../models/treino_dto.dart';
import '../models/exercicio_dto.dart';
import '../services/treino_service.dart';
import '../widgets/novo_exercicio_modal.dart';
import '../services/exercicio_service.dart';

class TreinoModal extends StatefulWidget {
  final String grupoId;
  final String alunoId;
  final List<ExercicioDTO> exercicios;
  final TreinoDTO? treinoExistente;

  const TreinoModal({
    super.key,
    required this.grupoId,
    required this.alunoId,
    required this.exercicios,
    this.treinoExistente,
  });

  @override
  State<TreinoModal> createState() => _TreinoModalState();
}

class _TreinoModalState extends State<TreinoModal> {
  late TextEditingController seriesController;
  late TextEditingController repMinController;
  late TextEditingController repMaxController;
  late TextEditingController pesoController;
  late TextEditingController observacaoController;
  String? selectedExercicioId;

  @override
  void initState() {
    super.initState();

    if (widget.treinoExistente != null) {
      selectedExercicioId = widget.treinoExistente!.exercicioId;
      seriesController = TextEditingController(
        text: widget.treinoExistente!.series.toString(),
      );
      repMinController = TextEditingController(
        text: widget.treinoExistente!.repMin.toString(),
      );
      repMaxController = TextEditingController(
        text: widget.treinoExistente!.repMax.toString(),
      );
      pesoController = TextEditingController(
        text: widget.treinoExistente!.pesoInicial.toString(),
      );
      observacaoController = TextEditingController(
        text: widget.treinoExistente!.observacao,
      );
    } else {
      seriesController = TextEditingController();
      repMinController = TextEditingController();
      repMaxController = TextEditingController();
      pesoController = TextEditingController();
      observacaoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    seriesController.dispose();
    repMinController.dispose();
    repMaxController.dispose();
    pesoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> salvarTreino() async {
  if (selectedExercicioId == null || widget.alunoId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Selecione um exercício")),
    );
    return;
  }

  // Verifica se já existe o treino com este exercício para este aluno
  final treinosExistentes = await TreinoService().listarPorGrupo(widget.grupoId);
  final existeDuplicado = treinosExistentes.any((t) =>
      t.exercicioId == selectedExercicioId &&
      t.alunoId == widget.alunoId &&
      t.id != widget.treinoExistente?.id // permite editar o mesmo registro
  );

  if (existeDuplicado) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Este exercício já foi cadastrado para este aluno"),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  final exercicio = widget.exercicios.firstWhere(
    (ex) => ex.id == selectedExercicioId,
  );

  final treino = TreinoDTO(
    id: widget.treinoExistente?.id,
    grupoId: widget.grupoId,
    alunoId: widget.alunoId,
    exercicioId: selectedExercicioId!,
    nomeExercicio: exercicio.nome,
    series: int.tryParse(seriesController.text) ?? exercicio.series,
    repMin: int.tryParse(repMinController.text) ?? exercicio.repMin,
    repMax: int.tryParse(repMaxController.text) ?? exercicio.repMax,
    pesoInicial: double.tryParse(pesoController.text) ?? exercicio.pesoInicial,
    diaDaSemana: widget.treinoExistente?.diaDaSemana ?? '',
    ordem: widget.treinoExistente?.ordem ?? 1,
    observacao: observacaoController.text,
  );

  try {
    if (widget.treinoExistente != null) {
      await TreinoService().editarTreino(treino);
    } else {
      await TreinoService().adicionarTreino(treino);
    }

    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.treinoExistente != null
                ? "Treino atualizado com sucesso"
                : "Treino criado com sucesso",
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar treino: $e"),
          backgroundColor: Colors.redAccent,
        
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
      filled: true,
      fillColor: theme.colorScheme.background,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.onSurface),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    TextStyle valorStyle = const TextStyle(
      color: Colors.purple,
      fontWeight: FontWeight.bold,
    );

    return AlertDialog(
  backgroundColor: Colors.black,
  title: Text(
    widget.treinoExistente != null ? "Editar Treino" : "Criar Treino",
    style: const TextStyle(color: Colors.white),
  ),
  content: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: selectedExercicioId,
          items: widget.exercicios.map((ex) {
            return DropdownMenuItem(
              value: ex.id,
              child: Text(
                ex.nome,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedExercicioId = value;
              final ex = widget.exercicios.firstWhere((e) => e.id == value);
              seriesController.text = ex.series.toString();
              repMinController.text = ex.repMin.toString();
              repMaxController.text = ex.repMax.toString();
              pesoController.text = ex.pesoInicial.toString();
            });
          },
          decoration: inputDecoration("Exercício"),
          dropdownColor: theme.colorScheme.surface,
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Novo exercício", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final novo = await showDialog<ExercicioDTO>(
                context: context,
                builder: (context) => const NovoExercicioModal(),
              );

              if (novo != null) {
                try {
                  final salvo = await ExercicioService().adicionarExercicio(novo);
                  setState(() {
                    widget.exercicios.add(salvo); 
                    selectedExercicioId = salvo.id;
                    seriesController.text = salvo.series.toString();
                    repMinController.text = salvo.repMin.toString();
                    repMaxController.text = salvo.repMax.toString();
                    pesoController.text = salvo.pesoInicial.toString();
                    observacaoController.text = salvo.observacao.toString();
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao adicionar exercício: $e"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: seriesController,
                keyboardType: TextInputType.number,
                style: valorStyle,
                decoration: inputDecoration("Séries"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repMinController,
                keyboardType: TextInputType.number,
                style: valorStyle,
                decoration: inputDecoration("Reps mínimas"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repMaxController,
                keyboardType: TextInputType.number,
                style: valorStyle,
                decoration: inputDecoration("Reps máximas"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                style: valorStyle,
                decoration: inputDecoration("Peso inicial (kg)"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: observacaoController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: inputDecoration("Observação"),
        ),
      ],
    ),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
    ),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      onPressed: salvarTreino,
      child: const Text("Salvar"),
    ),
  ],
);

  }
}
