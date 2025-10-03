class Aluno {
  final String id;
  final String nome;
  final String email;
  final String cpf;
  final String? fotoUrl;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    this.fotoUrl,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      cpf: json['cpf'],
      fotoUrl: json['fotoUrl'], // se tiver
    );
  }
}
