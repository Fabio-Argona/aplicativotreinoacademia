import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TreinoPage extends StatefulWidget {
  final String alunoId;
  final String alunoNome;

  const TreinoPage({required this.alunoId, required this.alunoNome, super.key});

  @override
  State<TreinoPage> createState() => _TreinoPageState();
}

class _TreinoPageState extends State<TreinoPage> {
  List<dynamic> grupos = [];
  Map<String, List<dynamic>> treinosPorGrupo = {};
  bool loading = true;

  final Color primaryColor = const Color(0xFFFF6F00);
  final Color accentColor = const Color(0xFFD84315);

  Map<String, String> basicHeaders() {
    const username = 'admin';
    const password = '1234';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }

  @override
  void initState() {
    super.initState();
    if (widget.alunoId.isNotEmpty) {
      carregarTreinos();
    } else {
      print("❌ alunoId está vazio. Não foi possível carregar os treinos.");
      setState(() => loading = false);
    }
  }

  Future<void> carregarTreinos() async {
    if (widget.alunoId.isEmpty) {
      print("❌ alunoId inválido. Abortando requisição.");
      setState(() => loading = false);
      return;
    }

    print("🔍 Carregando treinos para alunoId: ${widget.alunoId}");

    final gruposResponse = await http.get(
      Uri.parse(
        'http://localhost:8080/treinos/grupo?alunoId=${widget.alunoId}',
      ),
      headers: basicHeaders(),
    );

    if (gruposResponse.statusCode != 200) {
      setState(() => loading = false);
      print('❌ Erro ao buscar grupos: ${gruposResponse.statusCode}');
      return;
    }

    final List<dynamic> gruposData = json.decode(gruposResponse.body);
    final Map<String, List<dynamic>> agrupados = {};

    for (var grupo in gruposData) {
      final grupoId = grupo['id'];
      final exerciciosResponse = await http.get(
        Uri.parse('http://localhost:8080/treinos/$grupoId'),
        headers: basicHeaders(),
      );

      if (exerciciosResponse.statusCode == 200) {
        agrupados[grupoId] = json.decode(exerciciosResponse.body);
      } else {
        agrupados[grupoId] = [];
        print('⚠️ Erro ao buscar exercícios do grupo $grupoId');
      }
    }

    setState(() {
      grupos = gruposData;
      treinosPorGrupo = agrupados;
      loading = false;
    });
  }

  Future<void> removerTreino(String id) async {
    final url = Uri.parse('http://localhost:8080/treinos/$id');
    final response = await http.delete(url, headers: basicHeaders());

    if (response.statusCode == 204) {
      carregarTreinos();
    } else {
      print('Erro ao remover treino: ${response.statusCode}');
    }
  }

  void _criarGrupoTreino() async {
    final nomeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Criar novo grupo de treino"),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: "Nome do treino"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Criar"),
          ),
        ],
      ),
    );

    if (result == true && nomeController.text.isNotEmpty) {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      setState(() {
        grupos.add({
          'id': tempId,
          'nome': nomeController.text,
          'alunoId': widget.alunoId,
        });
        treinosPorGrupo[tempId] = [];
      });

      final response = await http.post(
        Uri.parse('http://localhost:8080/treinos/grupo'),
        headers: basicHeaders(),
        body: json.encode({
          "alunoId": widget.alunoId,
          "nome": nomeController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final grupoReal = json.decode(response.body);
        final realId = grupoReal['id'];

        setState(() {
          final index = grupos.indexWhere((g) => g['id'] == tempId);
          if (index != -1) {
            grupos[index] = grupoReal;
            treinosPorGrupo[realId] = treinosPorGrupo[tempId]!;
            treinosPorGrupo.remove(tempId);
          }
        });
      } else {
        print("❌ Erro ao salvar grupo: ${response.statusCode}");
      }
    }
  }

  void _adicionarExercicio(String grupoId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/exercicios'),
      headers: basicHeaders(),
    );

    if (response.statusCode != 200) {
      print('Erro ao buscar exercícios');
      return;
    }

    final List<dynamic> exercicios = json.decode(response.body);
    String? exercicioSelecionado;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar Exercício"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Escolha o exercício",
                ),
                value: exercicioSelecionado,
                items: exercicios.map<DropdownMenuItem<String>>((ex) {
                  return DropdownMenuItem<String>(
                    value: ex['id'].toString(),
                    child: Text(ex['nome'].toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    exercicioSelecionado = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );

    if (result == true && exercicioSelecionado != null) {
      final addResponse = await http.post(
        Uri.parse('http://localhost:8080/treinos'),
        headers: basicHeaders(),
        body: json.encode({
          "alunoId": widget.alunoId,
          "grupoId": grupoId,
          "exercicioId": exercicioSelecionado,
          "ordem": 1,
          "observacao": "Adicionado via app",
        }),
      );

      if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
        final novoExercicio = json.decode(addResponse.body);

        setState(() {
          if (treinosPorGrupo.containsKey(grupoId)) {
            treinosPorGrupo[grupoId]!.add(novoExercicio);
          } else {
            treinosPorGrupo[grupoId] = [novoExercicio];
          }
        });
      }
    }
  }

  Future<void> _removerGrupoTreino(String grupoId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/treinos/grupo/$grupoId'),
      headers: basicHeaders(),
    );

    if (response.statusCode == 204) {
      setState(() {
        grupos.removeWhere((g) => g['id'] == grupoId);
        treinosPorGrupo.remove(grupoId);
      });
    } else {
      print('❌ Erro ao remover grupo: ${response.statusCode}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover grupo')));
    }
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
            const Text("Treinos", style: TextStyle(fontSize: 18)),
            Text(
              "Vamos evoluir juntos, ${widget.alunoNome}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : grupos.isEmpty
          ? Center(
              child: Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.dumbbell,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Você ainda não tem treinos cadastrados.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: accentColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.plus),
                        label: const Text("Criar Treino"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _criarGrupoTreino,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, index) {
                final grupo = grupos[index];
                final grupoId = grupo['id'];
                final exercicios = treinosPorGrupo[grupoId] ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔝 Cabeçalho: nome do grupo + botão de deletar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                grupo['nome'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.trashCan,
                                color: Colors.red,
                              ),
                              onPressed: () => _removerGrupoTreino(grupoId),
                              tooltip: "Excluir grupo",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 📋 Lista de exercícios ou mensagem
                        if (exercicios.isEmpty)
                          Text(
                            "Nenhum exercício adicionado ainda.",
                            style: TextStyle(
                              color: accentColor.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Column(
                            children: exercicios.map((ex) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 0.5,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: primaryColor,
                                    child: Text(
                                      '${ex['ordem']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(ex['nomeExercicio']),
                                  subtitle: Text(
                                    '${ex['grupoMuscular'] ?? ''} • ${ex['observacao'] ?? ''}',
                                    style: TextStyle(
                                      color: accentColor.withOpacity(0.8),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.trashCan,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => removerTreino(ex['id']),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 12),

                        // 🔻 Rodapé: botão de adicionar exercício
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                            label: const Text("Adicionar Exercício"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _adicionarExercicio(grupoId),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _criarGrupoTreino,
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }
}
