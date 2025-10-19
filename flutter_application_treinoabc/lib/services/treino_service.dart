import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino_dto.dart';

class TreinoService {
  final String baseUrl = 'https://gym-manager-java.onrender.com/treinos';

  Future<void> adicionarTreino(TreinoDTO treino) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(treino.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Erro ao adicionar treino: ${response.body}');
    }
  }

  Future<List<TreinoDTO>> listarPorGrupo(String grupoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/grupo/$grupoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TreinoDTO.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Erro ao buscar treinos do grupo: ${response.body}');
    }
  }

  Future<void> editarTreino(TreinoDTO treino) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/${treino.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(treino.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao editar treino: ${response.body}');
    }
  }

  Future<void> excluirTreino(String treinoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/$treinoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir treino: ${response.body}');
    }
  }
}
