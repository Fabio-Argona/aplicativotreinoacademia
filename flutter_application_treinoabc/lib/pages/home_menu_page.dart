import 'package:flutter/material.dart';
import 'package:flutter_application_treinoabc/pages/treino_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'exercicio_page.dart';

class HomePage extends StatelessWidget {
  final String alunoId;
  final String alunoNome;
  final String alunoFotoUrl;

  const HomePage({
    super.key,
    required this.alunoId,
    required this.alunoNome,
    required this.alunoFotoUrl,
  });

  void abrirTreino(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreinoPage(
        alunoId: alunoId,
        alunoNome: alunoNome,
      ),
    ),
  );
}


  void abrirExercicios(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExerciciosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF6F00);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Olá, $alunoNome", style: const TextStyle(fontSize: 18)),
            const Text(
              "Sua jornada começa com atitude",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.green[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.dumbbell,
                  color: Colors.white,
                ),
                title: const Text(
                  'Treinos',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: const Text(
                  'Ver ou montar treinos',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => abrirTreino(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.clipboardList,
                  color: Colors.white,
                ),
                title: const Text(
                  'Exercícios',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: const Text(
                  'Catálogo de exercícios disponíveis',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => abrirExercicios(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


