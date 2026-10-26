import 'jogador.dart';

class Equipa {
  final String id;
  final String nome;
  final String brasaoUrl;
  final int vitorias;
  final int derrotas;
  final List<Jogador> jogadores;

  Equipa({
    required this.id,
    required this.nome,
    required this.brasaoUrl,
    this.vitorias = 0,
    this.derrotas = 0,
    this.jogadores = const [],
  });

  factory Equipa.fromJson(Map<String, dynamic> json) {
    return Equipa(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? 'Equipa Desconhecida',
      brasaoUrl:
          json['brasaoUrl']?.toString() ?? json['brasao']?.toString() ?? '',
      vitorias: json['vitorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
      jogadores: json['jogadores'] != null
          ? (json['jogadores'] as List)
              .map((j) => Jogador.fromJson(j as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'brasaoUrl': brasaoUrl,
      'vitorias': vitorias,
      'derrotas': derrotas,
    };
  }
}
