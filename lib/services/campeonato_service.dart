import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/classificacao.dart';
import '../models/equipa.dart';
import '../models/jogo.dart';
import '../models/jogador.dart';
import '../models/utilizador.dart';

class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CredenciaisInvalidasException extends ApiException {
  CredenciaisInvalidasException() : super('Usuário ou senha inválidos.');
}

class CampeonatoService {
  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

// AUTENTICAÇÃO
  Future<Utilizador> login(String usuario, String senha) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Utilizador/login');

    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'email': usuario, 'password': senha}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Utilizador.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CredenciaisInvalidasException();
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao tentar fazer login.',
      );
    } on CredenciaisInvalidasException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'Tempo de resposta excedido. Verifica se o servidor está online.',
      );
    } on FormatException {
      throw ApiException('A API devolveu um formato de dados inesperado.');
    } catch (e) {
      throw ApiException(
        'Não foi possível ligar ao servidor. Verifica a tua ligação.',
      );
    }
  }

// EQUIPAS
  Future<List<Equipa>> getEquipas() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Equipa');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body) as List<dynamic>;
        return dados
            .map((item) => Equipa.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao buscar equipas.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<Equipa> getEquipaPorId(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Equipa/$id');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return Equipa.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao buscar a equipa.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

// JOGADORES
  Future<Jogador> criarJogador(Jogador jogador, int idEquipa) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogador');

    final body = {
      'nome': jogador.nome,
      'numeroCamisola': jogador.numeroCamisola,
      'posicao': jogador.posicao,
      'golos': 0,
      'rematesFalhados': 0,
      'defesasComSucesso': 0,
      'defesasFalhadas': 0,
      'id_equipa': idEquipa,
    };

    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Jogador.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw ApiException(
        'Erro ${response.statusCode} ao criar o jogador.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<void> eliminarJogador(String jogadorId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogador/$jogadorId');

    try {
      final response =
          await http.delete(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Erro ${response.statusCode} ao eliminar o jogador.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<Jogador> atualizarEstatisticasJogador(
    String jogadorId,
    Map<String, dynamic> estatisticas,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogador/$jogadorId');

    try {
      final response = await http
          .put(uri, headers: _headers, body: jsonEncode(estatisticas))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Jogador.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao atualizar o jogador.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

// JOGOS
  Future<List<Jogo>> getJogos() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogo');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body) as List<dynamic>;
        return dados
            .map((item) => Jogo.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao buscar jogos.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<Jogo?> getUltimoJogo() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogo/ultimo');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return Jogo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      if (response.statusCode == 404) {
        return null;
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao buscar o último jogo.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<Jogo> criarJogo(Jogo jogo) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogo');

    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(jogo.toJson()))
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Jogo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao criar o jogo.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<void> atualizarPlacar(int jogoId, int golosCasa, int golosFora) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogo/$jogoId');

    try {
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode({
              'id_jogo': jogoId,
              'golos_casa': golosCasa,
              'golos_fora': golosFora,
              'data_jogo': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ApiException(
          'O servidor respondeu com erro ${response.statusCode} ao atualizar o placar.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

  Future<void> eliminarJogo(int jogoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Jogo/$jogoId');

    try {
      final response =
          await http.delete(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'O servidor respondeu com erro ${response.statusCode} ao eliminar o jogo.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }

// CLASSIFICAÇÃO
  Future<List<Classificacao>> getClassificacao() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Classificacao');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body) as List<dynamic>;
        return dados
            .map((item) => Classificacao.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode} ao buscar classificação.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Não foi possível ligar à API: $e');
    }
  }
}
