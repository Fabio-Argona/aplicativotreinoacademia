import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/treino.dart';

class TreinoService {
  final String username = 'admin';
  final String password = '1234';

  Future<List<Treino>> getTreinos(String alunoId) async {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      Uri.parse('http://localhost:8080/treinos/$alunoId/1'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => Treino.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar treinos');
    }
  }

  Future<List<Treino>> getTreinosDoAluno(String alunoId) async {
  return await getTreinos(alunoId);
}

  Future<void> criarTreino({
  required String alunoId,
  required String nome,
  required List<String> exercicioIds,
}) async {
  final basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

  final response = await http.post(
    Uri.parse('http://localhost:8080/treinos'),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'alunoId': alunoId,
      'nome': nome,
      'exercicioIds': exercicioIds,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Erro ao criar treino: ${response.statusCode}');
  }
}

}
