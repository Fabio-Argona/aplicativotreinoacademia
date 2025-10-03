import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/exercicio_service.dart';
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

  final Map<String, dynamic> exerciciosCache = {};

  Map<String, String> basicHeaders() {
    const username = 'admin';
    const password = '1234';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }

  String? _getExId(dynamic item) {
    try {
      if (item == null) return null;
      final v = item['exercicioId'] ?? item['exercicio']?['id'] ?? item['idExercicio'] ?? item['_exData']?['id'];
      return v?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureExerciciosCache() async {
    if (exerciciosCache.isNotEmpty) return;
    try {
      final allExResp = await http.get(
        Uri.parse('http://localhost:8080/exercicios'),
        headers: basicHeaders(),
      );
      if (allExResp.statusCode == 200) {
        final List<dynamic> allEx = json.decode(allExResp.body);
        for (var ex in allEx) {
          final id = ex['id']?.toString();
          if (id != null) exerciciosCache[id] = ex;
        }
      } else {
        print('⚠️ Não foi possível buscar lista de exercícios (status ${allExResp.statusCode}).');
      }
    } catch (e) {
      print('⚠️ Erro ao buscar lista de exercícios: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.alunoId.isNotEmpty) {
      carregarTreinos();
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> carregarTreinos() async {
    if (widget.alunoId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    try {
      await _ensureExerciciosCache();

      final gruposResponse = await http.get(
        Uri.parse('http://localhost:8080/treinos/grupo?alunoId=${widget.alunoId}'),
        headers: basicHeaders(),
      );

      if (gruposResponse.statusCode != 200) {
        print('❌ Erro ao buscar grupos: ${gruposResponse.statusCode}');
        setState(() => loading = false);
        return;
      }

      final List<dynamic> gruposData = json.decode(gruposResponse.body);
      final Map<String, List<dynamic>> agrupados = {};
      final exercicioService = ExercicioService();

      for (var grupo in gruposData) {
        final grupoId = grupo['id'].toString();
        final exerciciosResponse = await http.get(
          Uri.parse('http://localhost:8080/treinos/$grupoId'),
          headers: basicHeaders(),
        );

        if (exerciciosResponse.statusCode == 200) {
          List<dynamic> itens = json.decode(exerciciosResponse.body);

          for (var item in itens) {
            try {
              final exId = (item['exercicioId'] ?? item['exercicio']?['id'] ?? item['idExercicio'])?.toString();
              Map<String, dynamic>? exData;
              if (exId != null && exerciciosCache.containsKey(exId)) {
                exData = exerciciosCache[exId] as Map<String, dynamic>?;
              } else if (exId != null) {
                try {
                  exData = await exercicioService.getExercicioById(exId);
                } catch (e) {
                  exData = null;
                }
              }

              final needsFill = item['series'] == null ||
                  item['pesoInicial'] == null ||
                  item['repMin'] == null ||
                  item['repMax'] == null ||
                  item['nomeExercicio'] == null ||
                  item['grupoMuscular'] == null;

              if (exData != null && needsFill) {
                item['_exData'] = exData;
                item['nomeExercicio'] = item['nomeExercicio'] ?? (exData['nome'] ?? exData['nomeExercicio']);
                if (item['series'] == null && exData.containsKey('series')) item['series'] = exData['series'];
                if (item['pesoInicial'] == null && exData.containsKey('pesoInicial')) item['pesoInicial'] = exData['pesoInicial'];
                if (item['pesoInicial'] == null) item['pesoInicial'] = exData['peso'] ?? exData['peso_inicial'];
                if (item['repMin'] == null && exData.containsKey('repMin')) item['repMin'] = exData['repMin'];
                if (item['repMax'] == null && exData.containsKey('repMax')) item['repMax'] = exData['repMax'];
                if (item['grupoMuscular'] == null && exData.containsKey('grupoMuscular')) item['grupoMuscular'] = exData['grupoMuscular'];
                if (item['grupoMuscular'] == null) item['grupoMuscular'] = exData['grupo'] ?? exData['grupo_muscular'];
              } else if (exId != null && exData != null) {
                item['_exData'] = exData;
              }

              item['nomeExercicio'] = item['nomeExercicio'] ?? 'Exercício';
            } catch (e) {
              print('Erro ao preencher item: $e');
            }
          }

          agrupados[grupoId] = itens;
        } else {
          agrupados[grupoId] = [];
          print('⚠️ Erro ao buscar exercícios do grupo $grupoId (status ${exerciciosResponse.statusCode})');
        }
      }

      setState(() {
        grupos = gruposData;
        treinosPorGrupo = agrupados;
        loading = false;
      });
    } catch (e) {
      print('Erro em carregarTreinos: $e');
      setState(() => loading = false);
    }
  }

  Future<void> removerTreino(String id) async {
    final url = Uri.parse('http://localhost:8080/treinos/$id');
    final response = await http.delete(url, headers: basicHeaders());

    if (response.statusCode == 204) {
      await carregarTreinos();
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
    await _ensureExerciciosCache();

    final response = await http.get(
      Uri.parse('http://localhost:8080/exercicios'),
      headers: basicHeaders(),
    );

    if (response.statusCode != 200) {
      print('Erro ao buscar exercícios');
      return;
    }

    final List<dynamic> exercicios = json.decode(response.body);
    final exercicioService = ExercicioService();

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar Exercício"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exercicios.length,
              itemBuilder: (context, index) {
                final ex = exercicios[index];
                return ListTile(
                  title: Text(ex['nome'] ?? 'Exercício'),
                  subtitle: Text(ex['grupoMuscular'] ?? ''),
                  trailing: const FaIcon(
                    FontAwesomeIcons.plus,
                    color: Colors.green,
                  ),
                  onTap: () async {
                    final selectedId = ex['id']?.toString();
                    final exists = (treinosPorGrupo[grupoId] ?? []).any((t) => _getExId(t) == selectedId);

                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exercício já existe neste treino')),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    final addResponse = await http.post(
                      Uri.parse('http://localhost:8080/treinos'),
                      headers: basicHeaders(),
                      body: json.encode({
                        "alunoId": widget.alunoId,
                        "grupoId": grupoId,
                        "exercicioId": ex['id'].toString(),
                        "ordem": 1,
                      }),
                    );

                    if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
                      final novoExercicio = json.decode(addResponse.body);

                      Map<String, dynamic>? exData;
                      if (selectedId != null && exerciciosCache.containsKey(selectedId)) {
                        exData = exerciciosCache[selectedId] as Map<String, dynamic>?;
                      } else if (selectedId != null) {
                        try {
                          exData = await exercicioService.getExercicioById(selectedId);
                        } catch (_) {
                          exData = null;
                        }
                      }

                      if (exData != null) {
                        novoExercicio['_exData'] = exData;
                        novoExercicio['nomeExercicio'] = novoExercicio['nomeExercicio'] ?? (exData['nome'] ?? exData['nomeExercicio']);
                        if (novoExercicio['series'] == null && exData.containsKey('series')) novoExercicio['series'] = exData['series'];
                        if (novoExercicio['pesoInicial'] == null) novoExercicio['pesoInicial'] = exData['pesoInicial'] ?? exData['peso'] ?? exData['peso_inicial'];
                        if (novoExercicio['repMin'] == null && exData.containsKey('repMin')) novoExercicio['repMin'] = exData['repMin'];
                        if (novoExercicio['repMax'] == null && exData.containsKey('repMax')) novoExercicio['repMax'] = exData['repMax'];
                        novoExercicio['grupoMuscular'] = novoExercicio['grupoMuscular'] ?? exData['grupoMuscular'] ?? exData['grupo'] ?? exData['grupo_muscular'];
                      }

                      setState(() {
                        treinosPorGrupo[grupoId]?.add(novoExercicio);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exercício adicionado')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao adicionar exercício')),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao remover grupo')));
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
                    final grupoId = grupo['id'].toString();
                    final exercicios = treinosPorGrupo[grupoId] ?? [];

                    final Map<String, List<dynamic>> porMusculo = {};
                    for (var ex in exercicios) {
                      final fallback = (ex is Map) ? (ex['_exData'] as Map<String, dynamic>?) : null;
                      final muscle = (ex['grupoMuscular'] ?? fallback?['grupoMuscular'] ?? fallback?['grupo'] ?? 'Outros').toString();
                      porMusculo.putIfAbsent(muscle, () => []).add(ex);
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      grupo['nome'] ?? '',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.trashCan, color: Colors.red),
                                    onPressed: () => _removerGrupoTreino(grupoId),
                                    tooltip: "Excluir grupo",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (porMusculo.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Nenhum exercício adicionado ainda.",
                                  style: TextStyle(
                                    color: accentColor.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: porMusculo.entries.map((entry) {
                                  final muscle = entry.key;
                                  final items = entry.value;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        muscle,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor.withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ...items.map((ex) {
                                        final fallback = (ex is Map) ? (ex['_exData'] as Map<String, dynamic>?) : null;
                                        final nome = ex['nomeExercicio'] ?? fallback?['nome'] ?? 'Exercício';
                                        final series = ex['series'] ?? fallback?['series'];
                                        final peso = ex['pesoInicial'] ?? fallback?['pesoInicial'] ?? fallback?['peso'] ?? fallback?['peso_inicial'];
                                        final repMin = ex['repMin'] ?? fallback?['repMin'];
                                        final repMax = ex['repMax'] ?? fallback?['repMax'];
                                        final obs = ex['observacao'] ?? '';

                                        final List<String> parts = [];
                                        if (series != null) parts.add('Séries: $series');
                                        if (peso != null) parts.add('Peso: ${peso}kg');
                                        if (repMin != null || repMax != null) parts.add('Reps: ${repMin ?? '-'}-${repMax ?? '-'}');
                                        if (obs.isNotEmpty) parts.add(obs);

                                        final subtitleText = parts.join(' • ');

                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                                              leading: CircleAvatar(
                                                backgroundColor: primaryColor,
                                                child: const FaIcon(
                                                  FontAwesomeIcons.weightHanging,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              title: Text(nome),
                                              subtitle: subtitleText.isNotEmpty
                                                  ? Text(subtitleText, style: TextStyle(color: accentColor.withOpacity(0.8)))
                                                  : null,
                                              trailing: IconButton(
                                                icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.red),
                                                onPressed: () => removerTreino(ex['id'].toString()),
                                              ),
                                            ),
                                            const Divider(height: 1),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                                label: const Text("Adicionar Exercício"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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