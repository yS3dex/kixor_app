class Jogo {
  final int idJogo;
  final int equipaCasa;
  final int equipaFora;
  final int golosCasa;
  final int golosFora;
  final DateTime dataJogo;
  final String estadio;
  final String fase;

  Jogo({
    required this.idJogo,
    required this.equipaCasa,
    required this.equipaFora,
    required this.golosCasa,
    required this.golosFora,
    required this.dataJogo,
    required this.estadio,
    required this.fase,
  });

  factory Jogo.fromJson(Map<String, dynamic> json) {
    return Jogo(
      idJogo: json['id_jogo'] ?? 0,
      equipaCasa: json['equipa_casa'] ?? 0,
      equipaFora: json['equipa_fora'] ?? 0,
      golosCasa: json['golos_casa'] ?? 0,
      golosFora: json['golos_fora'] ?? 0,
      dataJogo: DateTime.parse(json['data_jogo'] ?? DateTime.now().toString()),
      estadio: json['estadio'] ?? 'Estádio Municipal',
      fase: json['fase'] ?? 'Fase de Grupos',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jogo': idJogo,
      'equipa_casa': equipaCasa,
      'equipa_fora': equipaFora,
      'golos_casa': golosCasa,
      'golos_fora': golosFora,
      'data_jogo': dataJogo.toIso8601String(),
      'estadio': estadio,
      'fase': fase,
    };
  }
}
