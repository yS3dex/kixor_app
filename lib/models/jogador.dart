class Jogador {
  final String id;
  final String nome;
  final int numeroCamisola;
  final String posicao;
  final int golos;
  final int rematesFalhados;
  final int defesasComSucesso;
  final int defesasFalhadas;

  Jogador({
    required this.id,
    required this.nome,
    required this.numeroCamisola,
    required this.posicao,
    this.golos = 0,
    this.rematesFalhados = 0,
    this.defesasComSucesso = 0,
    this.defesasFalhadas = 0,
  });

  bool get isGuardaRedes =>
      posicao.toLowerCase().contains('guarda') ||
      posicao.toLowerCase().contains('goleiro');

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? 'Sem nome',
      numeroCamisola: _parseInt(json['numeroCamisola'] ?? json['camisola']),
      posicao: json['posicao']?.toString() ?? 'Indefinida',
      golos: _parseInt(json['golos']),
      rematesFalhados: _parseInt(json['rematesFalhados'] ?? json['falhas']),
      defesasComSucesso:
          _parseInt(json['defesasComSucesso'] ?? json['defesasSucesso']),
      defesasFalhadas: _parseInt(json['defesasFalhadas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'numeroCamisola': numeroCamisola,
      'posicao': posicao,
      'golos': golos,
      'rematesFalhados': rematesFalhados,
      'defesasComSucesso': defesasComSucesso,
      'defesasFalhadas': defesasFalhadas,
    };
  }

  Jogador copyWith({
    int? golos,
    int? rematesFalhados,
    int? defesasComSucesso,
    int? defesasFalhadas,
  }) {
    return Jogador(
      id: id,
      nome: nome,
      numeroCamisola: numeroCamisola,
      posicao: posicao,
      golos: golos ?? this.golos,
      rematesFalhados: rematesFalhados ?? this.rematesFalhados,
      defesasComSucesso: defesasComSucesso ?? this.defesasComSucesso,
      defesasFalhadas: defesasFalhadas ?? this.defesasFalhadas,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
