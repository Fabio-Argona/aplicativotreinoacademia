import 'package:flutter/material.dart';
import '../models/exercicio.dart';
import '../services/exercicio_service.dart';

class CriarExercicioPage extends StatefulWidget {
  const CriarExercicioPage({super.key});

  @override
  State<CriarExercicioPage> createState() => _CriarExercicioPageState();
}

class _CriarExercicioPageState extends State<CriarExercicioPage> {
  final _service = ExercicioService();
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final seriesController = TextEditingController();
  final repMinController = TextEditingController();
  final repMaxController = TextEditingController();
  final pesoController = TextEditingController();
  final obsController = TextEditingController();

  String? grupoSelecionado;
  bool loading = false;
  double opacity = 0;

  final List<String> gruposMusculares = [
    'Peito',
    'Costas',
    'Pernas',
    'Ombros',
    'Bíceps',
    'Tríceps',
    'Abdômen',
    'Glúteos',
  ];

  final List<String> nomesExercicios = [
    'Supino reto barra',
    'Agachamento livre',
    'Remada curvada',
    'Rosca direta',
    'Tríceps corda',
    'Elevação lateral',
    'Prancha abdominal',
  ];

  double sugestaoDeCarga(String grupo) {
    switch (grupo) {
      case 'Peito': return 40;
      case 'Costas': return 50;
      case 'Pernas': return 60;
      case 'Ombros': return 30;
      case 'Bíceps': return 20;
      case 'Tríceps': return 25;
      case 'Abdômen': return 10;
      case 'Glúteos': return 35;
      default: return 20;
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final novo = Exercicio(
      id: '',
      nome: nomeController.text,
      grupoMuscular: grupoSelecionado!,
      series: int.parse(seriesController.text),
      repMin: int.parse(repMinController.text),
      repMax: int.parse(repMaxController.text),
      pesoInicial: double.parse(pesoController.text),
      observacao: obsController.text,
    );

    try {
      await _service.adicionarExercicio(novo);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: opacity,
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo Exercício')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Center(child: Icon(Icons.fitness_center, size: 64, color: Colors.blueAccent)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.search),
                      itemBuilder: (context) => nomesExercicios.map((nome) {
                        return PopupMenuItem(value: nome, child: Text(nome));
                      }).toList(),
                      onSelected: (value) => setState(() => nomeController.text = value),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                DropdownButtonFormField<String>(
                  value: grupoSelecionado,
                  items: gruposMusculares.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, size: 18),
                          const SizedBox(width: 8),
                          Text(g),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      grupoSelecionado = value;
                      pesoController.text = sugestaoDeCarga(value!).toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                  validator: (v) => v == null ? 'Selecione um grupo muscular' : null,
                ),
                TextFormField(controller: seriesController, decoration: const InputDecoration(labelText: 'Séries'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: repMinController, decoration: const InputDecoration(labelText: 'Repetições Mínimas'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: repMaxController, decoration: const InputDecoration(labelText: 'Repetições Máximas'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: pesoController, decoration: const InputDecoration(labelText: 'Peso Inicial'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: obsController, decoration: const InputDecoration(labelText: 'Observação')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : salvar,
                  child: loading ? const CircularProgressIndicator() : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
