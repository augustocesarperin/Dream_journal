import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../modelos/sonho.dart';

class ServicoApiCloudflare {
  final String _baseUrl;
  final _uuid = const Uuid();
  static const _chaveSonhos = 'sonhos_journal';

  ServicoApiCloudflare() : _baseUrl = dotenv.env['CLOUDFLARE_API_ENDPOINT'] ?? 'https://dreamlynch2.gutoperin.workers.dev/';

  Future<String> obterInterpretacao(String descricaoSonho) async {
    try {
      if (descricaoSonho.trim().isEmpty) {
        return 'Não é possível interpretar um sonho vazio. Por favor, descreva seu sonho em detalhes.';
      }
      
      final payload = jsonEncode({'descricaoSonho': descricaoSonho});
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('A conexão expirou. Verifique sua conexão com a internet e tente novamente.');
        },
      );

      debugPrint('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final interpretacao = data['interpretacao'];
          
          if (interpretacao == null || interpretacao.toString().isEmpty) {
            return 'Não foi possível interpretar seu sonho. A resposta da API não contém uma interpretação válida.';
          }
          
          if (interpretacao.toString().contains('As cortinas vermelhas se fecharam temporariamente')) {
            if (descricaoSonho.length > 100) {
              return 'As cortinas vermelhas estão oscilando. Tente novamente com uma descrição mais curta ou aguarde alguns instantes.';
            }
            
            return 'As cortinas vermelhas se fecharam temporariamente. Por favor, tente novamente mais tarde.';
          }
          
          return interpretacao;
        } catch (e) {
          debugPrint('Erro ao decodificar resposta JSON: $e');
          return 'Não foi possível processar a interpretação do sonho. Erro no formato da resposta.';
        }
      } else {
        return 'As cortinas vermelhas se fecharam temporariamente. Código: ${response.statusCode}. ${_obterMensagemErro(response.statusCode)}';
      }
    } catch (e) {
      debugPrint('Exceção: $e');
      return 'As cortinas vermelhas se fecharam temporariamente. Como em um salão enigmático, sua interpretação existe, mas está momentaneamente além do alcance.';
    }
  }

  String _obterMensagemErro(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida.';
      case 401:
        return 'Não autorizado.';
      case 403:
        return 'Acesso proibido.';
      case 404:
        return 'Endpoint não encontrado.';
      case 405:
        return 'Método não permitido. O endpoint só aceita requisições POST.';
      case 500:
        return 'Erro interno do servidor.';
      case 503:
        return 'Serviço indisponível.';
      default:
        return 'Erro desconhecido.';
    }
  }

  Future<List<Sonho>> obterSonhos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sonhosJson = prefs.getStringList(_chaveSonhos) ?? [];
      
      final sonhos = sonhosJson
          .map((json) => Sonho.fromJson(jsonDecode(json)))
          .toList();
      
      sonhos.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
      
      return sonhos;
    } catch (e) {
      debugPrint('Erro ao obter sonhos: $e');
      return [];
    }
  }

  Future<Sonho?> salvarSonho(String titulo, String descricao, String interpretacao) async {
    try {
      final id = _uuid.v4();
      final dataCriacao = DateTime.now();
      
      final sonho = Sonho(
        id: id,
        titulo: titulo,
        descricao: descricao,
        interpretacao: interpretacao,
        dataCriacao: dataCriacao,
      );
      
      final prefs = await SharedPreferences.getInstance();
      final sonhosJson = prefs.getStringList(_chaveSonhos) ?? [];
      
      sonhosJson.add(jsonEncode(sonho.toJson()));
      final resultado = await prefs.setStringList(_chaveSonhos, sonhosJson);
      
      if (!resultado) {
        debugPrint('Falha ao salvar no SharedPreferences');
        return null;
      }
      
      return sonho;
    } catch (e) {
      debugPrint('Erro ao salvar sonho: $e');
      return null;
    }
  }

  Future<Sonho?> obterSonho(String id) async {
    try {
      final sonhos = await obterSonhos();
      return sonhos.firstWhere((sonho) => sonho.id == id);
    } catch (e) {
      debugPrint('Erro ao obter sonho específico: $e');
      return null;
    }
  }
} 