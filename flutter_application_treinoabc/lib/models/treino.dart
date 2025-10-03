import 'exercicio.dart';

class Treino {
  final int id;
  final String nome;
  final String data; // se precisar da data
  List<Exercicio> exercicios; // <- adicionar esse atributo

  Treino({
    required this.id,
    required this.nome,
    required this.data,
    required this.exercicios,
  });

  factory Treino.fromJson(Map<String, dynamic> json) {
    return Treino(
      id: json['id'],
      nome: json['nome'],
      data: json['data'] ?? '',
      exercicios: (json['exercicios'] as List<dynamic>?)
              ?.map((e) => Exercicio.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data': data,
      'exercicios': exercicios.map((e) => e.toJson()).toList(),
    };
  }
}
