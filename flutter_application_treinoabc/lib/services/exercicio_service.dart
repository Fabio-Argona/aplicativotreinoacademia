import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercicio_dto.dart';

class ExercicioService {
  final String baseUrl = 'https://gym-manager-java.onrender.com/exercicios';

  Future<List<ExercicioDTO>> listar() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ExercicioDTO.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar exercícios');
    }
  }

  Future<ExercicioDTO> adicionarExercicio(ExercicioDTO exercicio) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(exercicio.toJson()),
  );

  if (response.statusCode == 201) {
    return ExercicioDTO.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Erro ao adicionar exercício');
  }
}

}
