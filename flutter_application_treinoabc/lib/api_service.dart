import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> buscarAlunos() async {
  final String username = 'admin';
  final String password = '1234';
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));

  final response = await http.get(
    Uri.parse('http://localhost:8080/alunos'),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print(response.body);
  } else {
    print('Erro: ${response.statusCode} ${response.reasonPhrase}');
  }
}
