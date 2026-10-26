class Classificacao {
  final int idEquipa;
  final String nomeEquipa;
  final int pontos;
  final int golosMarcados;
  final int golosSofridos;
  final int diferencaGolos;

  Classificacao({
    required this.idEquipa,
    required this.nomeEquipa,
    required this.pontos,
    required this.golosMarcados,
    required this.golosSofridos,
    required this.diferencaGolos,
  });

  factory Classificacao.fromJson(Map<String, dynamic> json) {
    return Classificacao(
      idEquipa: json['id_equipa'] as int? ?? 0,
      nomeEquipa: json['nome_equipa']?.toString() ?? '',
      pontos: json['pontos'] as int? ?? 0,
      golosMarcados: json['golos_marcados'] as int? ?? 0,
      golosSofridos: json['golos_sofridos'] as int? ?? 0,
      diferencaGolos: json['diferenca_golos'] as int? ?? 0,
    );
  }
}
