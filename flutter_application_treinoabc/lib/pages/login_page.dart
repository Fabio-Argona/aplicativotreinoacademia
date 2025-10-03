import 'package:flutter/material.dart';
import '../services/aluno_service.dart';
import '../pages/home_menu_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  final service = AlunoService();
  bool _loading = false;
  String? _error;

  final Color primaryColor = const Color(0xFFFF6F00);
  final Color accentColor = const Color(0xFFD84315);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Treino Full Performance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Sua jornada começa aqui",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.dumbbell, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    "Bem-vindo de volta!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    "Energia, ação, motivação",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: accentColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: "Login",
                      labelStyle: TextStyle(color: primaryColor),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.userAstronaut,
                          color: primaryColor,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      labelStyle: TextStyle(color: primaryColor),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.lock,
                          color: primaryColor,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 24),
                  if (_loading) const CircularProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _loading ? null : _login,
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final aluno = await service.login(
        _loginController.text.trim(),
        _senhaController.text.trim(),
      );

      if (aluno != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              alunoNome: aluno.nome,
              alunoFotoUrl: aluno.fotoUrl ?? '',
              alunoId: aluno.id,
            ),
          ),
        );
      } else {
        setState(() => _error = "Login ou senha inválidos");
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }
}
