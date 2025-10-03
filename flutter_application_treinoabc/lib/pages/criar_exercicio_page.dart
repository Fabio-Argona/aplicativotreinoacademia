import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  final Color primaryColor = const Color(0xFFFF6F00);
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

  final Map<String, IconData> grupoIcones = {
    'Peito': FontAwesomeIcons.dumbbell,
    'Costas': FontAwesomeIcons.personSwimming,
    'Pernas': FontAwesomeIcons.personRunning,
    'Ombros': FontAwesomeIcons.arrowsUpDown,
    'Bíceps': FontAwesomeIcons.handFist,
    'Tríceps': FontAwesomeIcons.handBackFist,
    'Abdômen': FontAwesomeIcons.personWalking,
    'Glúteos': FontAwesomeIcons.personHiking,
  };

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
      case 'Peito':
        return 40;
      case 'Costas':
        return 50;
      case 'Pernas':
        return 60;
      case 'Ombros':
        return 30;
      case 'Bíceps':
        return 20;
      case 'Tríceps':
        return 25;
      case 'Abdômen':
        return 10;
      case 'Glúteos':
        return 35;
      default:
        return 20;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
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
        backgroundColor: const Color(0xFFFFF3E0),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            'Novo Exercício',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 2,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Center(
                  child: FaIcon(
                    FontAwesomeIcons.dumbbell,
                    size: 64,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    suffixIcon: PopupMenuButton<String>(
                      icon: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: primaryColor,
                      ),
                      itemBuilder: (context) => nomesExercicios.map((nome) {
                        return PopupMenuItem(value: nome, child: Text(nome));
                      }).toList(),
                      onSelected: (value) =>
                          setState(() => nomeController.text = value),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: grupoSelecionado,
                  items: gruposMusculares.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Row(
                        children: [
                          FaIcon(
                            grupoIcones[g] ?? FontAwesomeIcons.dumbbell,
                            size: 18,
                            color: primaryColor,
                          ),
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
                  decoration: InputDecoration(
                    labelText: 'Grupo Muscular',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null ? 'Selecione um grupo muscular' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: seriesController,
                  decoration: InputDecoration(
                    labelText: 'Séries',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: repMinController,
                  decoration: InputDecoration(
                    labelText: 'Repetições Mínimas',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: repMaxController,
                  decoration: InputDecoration(
                    labelText: 'Repetições Máximas',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: pesoController,
                  decoration: InputDecoration(
                    labelText: 'Peso Inicial',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: obsController,
                  decoration: InputDecoration(
                    labelText: 'Observação',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
                  label: const Text('Salvar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: loading ? null : salvar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
