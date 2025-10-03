import 'dart:convert';
import 'package:flutter_application_treinoabc/models/aluno.dart';
import 'package:http/http.dart' as http;

class AlunoService {
  final String baseUrl = "http://localhost:8080";

  final String username = "admin";
  final String password = "1234";

  String get _basicAuth =>
      'Basic ' + base64Encode(utf8.encode('$username:$password'));

  // Busca todos os alunos
  Future<List<Aluno>> getAlunos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Aluno.fromJson(json)).toList();
    } else {
      throw Exception("Erro ao buscar alunos: ${response.statusCode}");
    }
  }

  Future<Aluno?> login(String email, String cpf) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'cpf': cpf}),
    );

    if (response.statusCode == 200) {
      return Aluno.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      return null; // login inválido
    } else {
      throw Exception('Erro no login: ${response.statusCode}');
    }
  }

  Future<Aluno> buscarAlunoPorId(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos/$id'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Aluno.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao buscar aluno por ID: ${response.statusCode}');
    }
  }
}
