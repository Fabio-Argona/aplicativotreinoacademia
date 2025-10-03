import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<bool> login(String username, String password) async {
    final basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      Uri.parse('http://localhost:8080/alunos'), // endpoint de teste
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
