import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercicio.dart';

class ExercicioService {
  final String username = 'admin';
  final String password = '1234';
  final String baseUrl = 'http://localhost:8080';

  Map<String, String> get _headers {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };
  }

  // ==================== CRUD Exercícios ====================

  // Listar todos os exercícios
  Future<List<Exercicio>> getExercicios() async {
    final response = await http.get(Uri.parse('$baseUrl/exercicios'), headers: _headers);
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => Exercicio.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar exercícios: ${response.statusCode}');
    }
  }

  // Adicionar exercício
  Future<Exercicio> adicionarExercicio(Exercicio exercicio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exercicios'),
      headers: _headers,
      body: jsonEncode(exercicio.toJson()),
    );
    if (response.statusCode == 201) {
      return Exercicio.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao adicionar exercício');
    }
  }

  // Editar exercício
  Future<Exercicio> editarExercicio(Exercicio exercicio) async {
    final response = await http.put(
      Uri.parse('$baseUrl/exercicios/${exercicio.id}'),
      headers: _headers,
      body: jsonEncode(exercicio.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return exercicio;
    } else {
      throw Exception('Erro ao editar exercício');
    }
  }

  // Deletar exercício
  Future<void> deletarExercicio(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/exercicios/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar exercício');
    }
  }

  // ==================== Treino do aluno ====================

  // Listar exercícios de um treino do aluno
  Future<List<Exercicio>> getTreino(String alunoNome, String treinoNome) async {
    final response = await http.get(
      Uri.parse('$baseUrl/treinoExercicios/$alunoNome/$treinoNome'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => Exercicio.fromJson(e['exercicio'])).toList();
    } else {
      throw Exception('Erro ao buscar treino: ${response.statusCode}');
    }
  }

  // Adicionar exercício no treino do aluno
  Future<void> adicionarExercicioNoTreino(String alunoNome, String treinoNome, String exercicioId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/treinoExercicios'),
      headers: _headers,
      body: jsonEncode({
        'alunoNome': alunoNome,
        'treinoNome': treinoNome,
        'exercicio': {'id': exercicioId},
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar exercício no treino');
    }
  }

  // Remover exercício do treino do aluno
  Future<void> removerExercicioDoTreino(String alunoNome, String treinoNome, String exercicioId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/treinoExercicios/$alunoNome/$treinoNome/$exercicioId'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao remover exercício do treino');
    }
  }
}
