import 'package:flutter/material.dart';
import '../models/exercicio_dto.dart';

class NovoExercicioModal extends StatefulWidget {
  const NovoExercicioModal({super.key});

  @override
  State<NovoExercicioModal> createState() => _NovoExercicioModalState();
}

class _NovoExercicioModalState extends State<NovoExercicioModal> {
  final nomeController = TextEditingController();
  final seriesController = TextEditingController();
  final repMinController = TextEditingController(text: '10');
  final repMaxController = TextEditingController(text: '12');
  final pesoController = TextEditingController(text: '20');
  final obsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<String> ordemGrupos = [
    'Peito',
    'Costas',
    'Tríceps',
    'Bíceps',
    'Ombro',
    'Perna',
    'Abdômen',
    'Panturrilha',
  ];

  String? grupoSelecionado;

  InputDecoration inputDecoration(String label, ThemeData theme) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.background,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.onSurface),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text("Novo Exercício", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: inputDecoration("Nome", theme),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: grupoSelecionado,
                items: ordemGrupos.map((grupo) {
                  return DropdownMenuItem(
                    value: grupo,
                    child: Text(grupo),
                  );
                }).toList(),
                onChanged: (value) => setState(() => grupoSelecionado = value),
                decoration: inputDecoration("Grupo Muscular", theme),
                dropdownColor: theme.colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null ? "Selecione um grupo" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: seriesController,
                decoration: inputDecoration("Séries", theme),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: repMinController,
                      decoration: inputDecoration("Reps mínimas", theme),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: repMaxController,
                      decoration: inputDecoration("Reps máximas", theme),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pesoController,
                decoration: inputDecoration("Peso inicial (kg)", theme),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: obsController,
                decoration: inputDecoration("Observação", theme),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final novo = ExercicioDTO(
                id: '',
                nome: nomeController.text.trim(),
                grupoMuscular: grupoSelecionado!,
                series: int.tryParse(seriesController.text) ?? 3,
                repMin: int.tryParse(repMinController.text) ?? 10,
                repMax: int.tryParse(repMaxController.text) ?? 12,
                pesoInicial: double.tryParse(pesoController.text) ?? 20.0,
                observacao: obsController.text.trim(),
              );
              Navigator.pop(context, novo);
            }
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}
