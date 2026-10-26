class Utilizador {
  final int idUtilizador;
  final String nome;
  final String email;
  final int idPerfil;
  final int? idEquipa;

  Utilizador({
    required this.idUtilizador,
    required this.nome,
    required this.email,
    required this.idPerfil,
    this.idEquipa,
  });

  factory Utilizador.fromJson(Map<String, dynamic> json) {
    return Utilizador(
      idUtilizador: json['id_utilizador'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      idPerfil: json['id_perfil'] as int,
      idEquipa: json['id_equipa'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_utilizador': idUtilizador,
      'nome': nome,
      'email': email,
      'id_perfil': idPerfil,
      'id_equipa': idEquipa,
    };
  }
}
