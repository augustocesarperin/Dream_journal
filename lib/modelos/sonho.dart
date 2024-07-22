class Sonho {
  final String id;
  final String titulo;
  final String descricao;
  final String interpretacao;
  final DateTime dataCriacao;

  Sonho({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.interpretacao,
    required this.dataCriacao,
  });

  Sonho copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? interpretacao,
    DateTime? dataCriacao,
  }) {
    return Sonho(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      interpretacao: interpretacao ?? this.interpretacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  factory Sonho.fromJson(Map<String, dynamic> json) {
    return Sonho(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      interpretacao: json['interpretacao'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'interpretacao': interpretacao,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }
}