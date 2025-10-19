import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino_grupo_dto.dart';
import '../services/grupo_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nome = '';
  String alunoId = '';
  late Future<List<TreinoGrupoDTO>> gruposFuture;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nomeSalvo = prefs.getString('aluno_nome') ?? '';
    final idSalvo = prefs.getString('aluno_id') ?? '';

    setState(() {
      nome = nomeSalvo;
      alunoId = idSalvo;
      gruposFuture = GrupoService().listarPorAluno(alunoId);
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<bool> confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deseja sair?"),
        content: const Text(
          "Você quer encerrar a sessão e voltar para o login?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sair"),
          ),
        ],
      ),
    );

    if (sair == true) {
      await logout();
      return true;
    }

    return false;
  }

  Future<void> mostrarModalGrupo({TreinoGrupoDTO? grupoExistente}) async {
    final TextEditingController nomeController = TextEditingController(
      text: grupoExistente?.nome ?? '',
    );

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(grupoExistente != null ? "Editar grupo" : "Criar grupo"),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: "Nome do grupo"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nomeNovo = nomeController.text.trim();
              if (nomeNovo.isEmpty) return;

              try {
                if (grupoExistente != null) {
                  await GrupoService().editarGrupo(grupoExistente.id, nomeNovo);
                } else {
                  await GrupoService().adicionarGrupo(
                    TreinoGrupoDTO(id: '', alunoId: alunoId, nome: nomeNovo),
                  );
                }

                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Erro ao ${grupoExistente != null ? 'editar' : 'criar'} grupo: $e",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (resultado == true) {
      setState(() {
        gruposFuture = GrupoService().listarPorAluno(alunoId);
      });
    }
  }

  Future<void> excluirGrupo(String grupoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir grupo"),
        content: const Text("Tem certeza que deseja excluir este grupo?"),
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

    if (confirm == true) {
      try {
        await GrupoService().removerGrupo(grupoId);
        setState(() {
          gruposFuture = GrupoService().listarPorAluno(alunoId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grupo excluído com sucesso"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao excluir grupo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: confirmarSaida,
      child: Scaffold(
  appBar: AppBar(
    automaticallyImplyLeading: false,
    title: const Text('Full Performance'),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: "Sair",
        onPressed: () async {
          final sair = await confirmarSaida();
          if (sair) await logout();
        },
      ),
    ],
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 20,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "Olá, ",
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextSpan(
                text: nome,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "! Seus grupos de treino:",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<TreinoGrupoDTO>>(
            future: gruposFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Nenhum grupo de treino encontrado'),
                );
              }

              final grupos = snapshot.data!;
              return ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupo = grupos[index];
                  return Card(
                    child: ListTile(
                      title: Text(grupo.nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white30),
                            onPressed: () =>
                                mostrarModalGrupo(grupoExistente: grupo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => excluirGrupo(grupo.id),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/treinos',
                          arguments: grupo.id,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => mostrarModalGrupo(),
    backgroundColor: Colors.deepPurple,
    child: const Icon(Icons.add, color: Colors.white),
  ),
));

  }
} 