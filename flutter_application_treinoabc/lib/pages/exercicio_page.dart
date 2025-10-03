import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/exercicio.dart';
import '../services/exercicio_service.dart';
import 'criar_exercicio_page.dart';

class ExerciciosPage extends StatefulWidget {
  const ExerciciosPage({super.key});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  final ExercicioService _exercicioService = ExercicioService();
  List<Exercicio> exercicios = [];
  bool _loading = true;

  final Color primaryColor = const Color(0xFFFF6F00);
  final Color accentColor = const Color(0xFFD84315);

  @override
  void initState() {
    super.initState();
    _loadExercicios();
  }

  Future<void> _loadExercicios() async {
    setState(() => _loading = true);
    try {
      exercicios = await _exercicioService.getExercicios();
    } catch (e) {
      print('Erro ao carregar exercícios: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _editarExercicio(Exercicio exercicio) async {
    final nomeController = TextEditingController(text: exercicio.nome);
    final grupoController = TextEditingController(
      text: exercicio.grupoMuscular,
    );
    final seriesController = TextEditingController(
      text: exercicio.series.toString(),
    );
    final repMinController = TextEditingController(
      text: exercicio.repMin.toString(),
    );
    final repMaxController = TextEditingController(
      text: exercicio.repMax.toString(),
    );
    final pesoController = TextEditingController(
      text: exercicio.pesoInicial.toString(),
    );
    final obsController = TextEditingController(
      text: exercicio.observacao ?? '',
    );

    final Color primaryColor = const Color(0xFFFF6F00);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Exercício'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: grupoController,
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: seriesController,
                keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repMinController,
                keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repMaxController,
                keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
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
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final atualizado = Exercicio(
          id: exercicio.id,
          nome: nomeController.text,
          grupoMuscular: grupoController.text,
          series: int.parse(seriesController.text),
          repMin: int.parse(repMinController.text),
          repMax: int.parse(repMaxController.text),
          pesoInicial: double.parse(pesoController.text),
          observacao: obsController.text,
        );

        await _exercicioService.editarExercicio(atualizado);
        await _loadExercicios();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _deletarExercicio(String id) async {
    try {
      await _exercicioService.deletarExercicio(id);
      await _loadExercicios();
    } catch (e) {
      String mensagem = e.toString().contains('409')
          ? 'Este exercício está vinculado a um treino. Remova do treino antes de apagar.'
          : 'Erro ao deletar exercício: Este exercício está vinculado a um treino. Remova do treino antes de apagar.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  void _abrirCriacaoExercicio() async {
    final sucesso = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CriarExercicioPage()),
    );
    if (sucesso == true) await _loadExercicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Adicione, remova ou crie exercícios",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const Text(
              "Construa sua força com consistência",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercicios.length,
              itemBuilder: (context, index) {
                final ex = exercicios[index];
                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.dumbbell,
                      color: Colors.orange,
                    ),
                    title: Text(
                      ex.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Text(
                      '${ex.grupoMuscular} • ${ex.series}x${ex.repMin}-${ex.repMax} • ${ex.pesoInicial}kg',
                      style: TextStyle(color: accentColor.withOpacity(0.8)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.penToSquare,
                            color: Colors.blue,
                          ),
                          onPressed: () => _editarExercicio(ex),
                        ),
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.trashCan,
                            color: Colors.red,
                          ),
                          onPressed: () => _deletarExercicio(ex.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _abrirCriacaoExercicio,
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }
}
