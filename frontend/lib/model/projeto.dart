class Projeto {
  final String id;
  final String titulo;
  final String descricao;
  final String resumoIa;
  final String status;

  Projeto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.resumoIa,
    required this.status,
  });

  factory Projeto.fromJson(Map<String, dynamic> json) {
    return Projeto(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      resumoIa: json['resumoIa'] ?? '',
      status: json['status'] ?? '',
    );
  }
}