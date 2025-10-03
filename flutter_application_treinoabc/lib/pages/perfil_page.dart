import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/aluno_service.dart';

class PerfilPage extends StatefulWidget {
  final String alunoId;

  const PerfilPage({super.key, required this.alunoId});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final Color primaryColor = const Color(0xFFFF6F00);
  final service = AlunoService();

  String? nome;
  String? fotoUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final aluno = await service.buscarAlunoPorId(widget.alunoId);
    setState(() {
      nome = aluno.nome;
      fotoUrl = aluno.fotoUrl;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Perfil do Aluno"),
        centerTitle: true,
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: fotoUrl != null && fotoUrl!.isNotEmpty
                        ? NetworkImage(fotoUrl!)
                        : const AssetImage('lib/assets/images/feminino.jpg') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nome ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Disciplina é a ponte entre metas e conquistas.",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Column(
                        children: [
                          FaIcon(FontAwesomeIcons.dumbbell, size: 32, color: Colors.green),
                          SizedBox(height: 8),
                          Text("Treinos"),
                        ],
                      ),
                      Column(
                        children: [
                          FaIcon(FontAwesomeIcons.bolt, size: 32, color: Colors.orange),
                          SizedBox(height: 8),
                          Text("Energia"),
                        ],
                      ),
                      Column(
                        children: [
                          FaIcon(FontAwesomeIcons.heartPulse, size: 32, color: Colors.red),
                          SizedBox(height: 8),
                          Text("Saúde"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
