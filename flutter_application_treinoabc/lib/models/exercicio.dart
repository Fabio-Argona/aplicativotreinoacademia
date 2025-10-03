class Exercicio {
  final String id;
  final String nome;
  final String grupoMuscular;
  final int series;
  final int repMin;
  final int repMax;
  final double pesoInicial;
  final String? observacao;

  Exercicio({
    required this.id,
    required this.nome,
    required this.grupoMuscular,
    required this.series,
    required this.repMin,
    required this.repMax,
    required this.pesoInicial,
    this.observacao,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      grupoMuscular: json['grupoMuscular'] ?? '',
      series: json['series'] ?? 0,
      repMin: json['repMin'] ?? 0,
      repMax: json['repMax'] ?? 0,
      pesoInicial: (json['pesoInicial'] as num?)?.toDouble() ?? 0.0,
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'grupoMuscular': grupoMuscular,
      'series': series,
      'repMin': repMin,
      'repMax': repMax,
      'pesoInicial': pesoInicial,
      'observacao': observacao,
    };
  }
}
