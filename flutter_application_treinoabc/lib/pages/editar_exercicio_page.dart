import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarExercicioPage extends StatefulWidget {
  final Map<String, dynamic> exercicio;

  const EditarExercicioPage({required this.exercicio, super.key});

  @override
  State<EditarExercicioPage> createState() => _EditarExercicioPageState();
}

class _EditarExercicioPageState extends State<EditarExercicioPage> {
  late TextEditingController nomeController;
  late TextEditingController grupoController;
  late TextEditingController seriesController;
  late TextEditingController repMinController;
  late TextEditingController repMaxController;
  late TextEditingController pesoController;
  late TextEditingController obsController;

  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final e = widget.exercicio;
    nomeController = TextEditingController(text: e['nome']);
    grupoController = TextEditingController(text: e['grupoMuscular']);
    seriesController = TextEditingController(text: e['series'].toString());
    repMinController = TextEditingController(text: e['repMin'].toString());
    repMaxController = TextEditingController(text: e['repMax'].toString());
    pesoController = TextEditingController(text: e['pesoInicial'].toString());
    obsController = TextEditingController(text: e['observacao'] ?? '');
  }

  Future<void> salvar() async {
    setState(() {
      loading = true;
      error = null;
    });

    final url = Uri.parse('http://localhost:8080/treinos/${widget.exercicio['id']}');
    final body = {
      'nome': nomeController.text,
      'grupoMuscular': grupoController.text,
      'series': int.parse(seriesController.text),
      'repMin': int.parse(repMinController.text),
      'repMax': int.parse(repMaxController.text),
      'pesoInicial': int.parse(pesoController.text),
      'observacao': obsController.text,
    };

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true); // volta com sucesso
    } else {
      setState(() => error = 'Erro ao salvar (${response.statusCode})');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Exercício')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: grupoController, decoration: const InputDecoration(labelText: 'Grupo Muscular')),
            TextField(controller: seriesController, decoration: const InputDecoration(labelText: 'Séries'), keyboardType: TextInputType.number),
            TextField(controller: repMinController, decoration: const InputDecoration(labelText: 'Repetições Mínimas'), keyboardType: TextInputType.number),
            TextField(controller: repMaxController, decoration: const InputDecoration(labelText: 'Repetições Máximas'), keyboardType: TextInputType.number),
            TextField(controller: pesoController, decoration: const InputDecoration(labelText: 'Peso Inicial'), keyboardType: TextInputType.number),
            TextField(controller: obsController, decoration: const InputDecoration(labelText: 'Observação')),
            const SizedBox(height: 20),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: loading ? null : salvar,
              child: loading ? const CircularProgressIndicator() : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
