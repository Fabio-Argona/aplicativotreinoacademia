import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino_grupo_dto.dart';

class GrupoService {
  final String baseUrl = 'https://gym-manager-java.onrender.com';

  // Listar grupos por aluno
  Future<List<TreinoGrupoDTO>> listarPorAluno(String alunoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (alunoId.isEmpty) {
      throw Exception('Aluno ID está vazio. Não é possível buscar grupos.');
    }

    final uri = Uri.parse('$baseUrl/grupos/aluno/$alunoId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => TreinoGrupoDTO.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Acesso negado. Verifique se o token está válido.');
    } else {
      throw Exception(
        'Erro ao buscar grupos de treino: ${response.statusCode}',
      );
    }
  }

  // Adicionar novo grupo
  Future<TreinoGrupoDTO> adicionarGrupo(TreinoGrupoDTO grupo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final uri = Uri.parse('$baseUrl/grupos');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: utf8.encode(jsonEncode(grupo.toJson())),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TreinoGrupoDTO.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 403) {
      throw Exception('Acesso negado. Verifique se o token está válido.');
    } else {
      throw Exception(
        'Erro ao criar grupo de treino: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Editar grupo existente (PATCH)
  Future<TreinoGrupoDTO> editarGrupo(String grupoId, String nomeNovo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final uri = Uri.parse('$baseUrl/grupos/$grupoId');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: utf8.encode(jsonEncode({'nome': nomeNovo})),
    );

    if (response.statusCode == 200) {
      return TreinoGrupoDTO.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 403) {
      throw Exception('Acesso negado. Verifique se o token está válido.');
    } else {
      throw Exception(
        'Erro ao editar grupo de treino: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Remover grupo
  Future<void> removerGrupo(String grupoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final uri = Uri.parse('$baseUrl/grupos/$grupoId');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 403) {
        throw Exception('Acesso negado. Verifique se o token está válido.');
      }
      throw Exception(
        'Erro ao remover grupo de treino: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
