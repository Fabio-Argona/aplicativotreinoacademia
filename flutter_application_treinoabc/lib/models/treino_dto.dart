class TreinoDTO {
  String? id;
  String grupoId;
  String alunoId;
  String exercicioId;
  String nomeExercicio;
  int series;
  int repMin;
  int repMax;
  double pesoInicial;
  String diaDaSemana;
  int ordem;
  String observacao;

  TreinoDTO({
    this.id,
    required this.grupoId,
    required this.alunoId,
    required this.exercicioId,
    required this.nomeExercicio,
    required this.series,
    required this.repMin,
    required this.repMax,
    required this.pesoInicial,
    required this.diaDaSemana,
    required this.ordem,
    required this.observacao,
  });

  factory TreinoDTO.fromJson(Map<String, dynamic> json) {
    return TreinoDTO(
      id: json['id'],
      grupoId: json['grupoId'],
      alunoId: json['alunoId'],
      exercicioId: json['exercicioId'],
      nomeExercicio: json['nomeExercicio'] ?? '',
      series: (json['series'] ?? 0) as int,
      repMin: (json['repMin'] ?? 0) as int,
      repMax: (json['repMax'] ?? 0) as int,
      pesoInicial: (json['pesoInicial'] ?? 0).toDouble(),
      diaDaSemana: json['diaSemana'] ?? '',
      ordem: (json['ordem'] ?? 1) as int,
      observacao: json['observacao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'grupoId': grupoId,
      'alunoId': alunoId,
      'exercicioId': exercicioId,
      'nomeExercicio': nomeExercicio,
      'series': series,
      'repMin': repMin,
      'repMax': repMax,
      'pesoInicial': pesoInicial,
      'diaSemana': diaDaSemana,
      'ordem': ordem,
      'observacao': observacao,
    };
  }
}
