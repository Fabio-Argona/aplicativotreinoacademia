class TreinoGrupoDTO {
  final String id;
  final String alunoId;
  final String nome;

  TreinoGrupoDTO({
    required this.id,
    required this.alunoId,
    required this.nome,
  });

  factory TreinoGrupoDTO.fromJson(Map<String, dynamic> json) {
    return TreinoGrupoDTO(
      id: json['id'] ?? '',
      alunoId: json['alunoId'] ?? '',
      nome: json['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alunoId': alunoId,
      'nome': nome,
    };
  }
}
