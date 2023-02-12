import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
    debugPrint('Iniciando interpretação com URL: $_baseUrl');
    debugPrint('Tamanho da descrição: ${descricaoSonho.length} caracteres');
    
    try {
      if (descricaoSonho.trim().isEmpty) {
        return 'Não é possível interpretar um sonho vazio. Por favor, descreva seu sonho em detalhes.';
      }
      
      final payload = jsonEncode({'descricaoSonho': descricaoSonho});
      debugPrint('Enviando payload: $payload');
      
      try {
        final testResponse = await http.get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 10));
        debugPrint('Teste de conectividade: ${testResponse.statusCode == 200 ? 'OK' : 'Falhou com código ${testResponse.statusCode}'}');
      } catch (e) {
        debugPrint('ERRO NO TESTE DE CONECTIVIDADE: $e');
        if (e is SocketException) {
          return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
        }
      }
      
      debugPrint('Fazendo requisição POST para: $_baseUrl');
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
          debugPrint('TIMEOUT na requisição após 60 segundos');
          throw TimeoutException('A conexão expirou. Verifique sua conexão com a internet e tente novamente.');
        },
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Resposta bruta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Resposta decodificada: $data');
          
          final interpretacao = data['interpretacao'];
          
          if (interpretacao == null || interpretacao.toString().isEmpty) {
            debugPrint('Interpretação vazia ou nula');
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
          debugPrint('ERRO ao decodificar resposta JSON: $e');
          debugPrint('Corpo da resposta: ${response.body}');
          return 'Não foi possível processar a interpretação do sonho. Erro no formato da resposta.';
        }
      } else {
        debugPrint('Resposta com erro: ${response.statusCode}, corpo: ${response.body}');
        return 'As cortinas vermelhas se fecharam temporariamente. Código: ${response.statusCode}. ${_obterMensagemErro(response.statusCode)}';
      }
    } catch (e) {
      debugPrint('EXCEÇÃO DETALHADA: $e');
      
      if (e is SocketException) {
        return 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
      } else if (e is HttpException) {
        return 'Erro na requisição HTTP. Algo está interferindo na comunicação.';
      } else if (e is FormatException) {
        return 'Formato de resposta inválido. O servidor respondeu de forma inesperada.';
      } else if (e.toString().contains('TimeoutException')) {
        return 'A conexão expirou. O servidor está demorando muito para responder.';
      }
      
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

  Future<bool> salvarSonho(Sonho sonho) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sonhosJson = prefs.getStringList(_chaveSonhos) ?? [];
      
      final sonhoAtualizado = sonho.id.isEmpty
          ? sonho.copyWith(id: _uuid.v4(), dataCriacao: DateTime.now())
          : sonho;
      
      final sonhos = sonhosJson
          .map((json) => Sonho.fromJson(jsonDecode(json)))
          .toList();
      
      final indexExistente = sonhos.indexWhere((s) => s.id == sonhoAtualizado.id);
      
      if (indexExistente >= 0) {
        sonhos[indexExistente] = sonhoAtualizado;
      } else {
        sonhos.add(sonhoAtualizado);
      }
      
      final sonhosAtualizadosJson = sonhos
          .map((s) => jsonEncode(s.toJson()))
          .toList();
      
      return await prefs.setStringList(_chaveSonhos, sonhosAtualizadosJson);
    } catch (e) {
      debugPrint('Erro ao salvar sonho: $e');
      return false;
    }
  }

  Future<bool> excluirSonho(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sonhosJson = prefs.getStringList(_chaveSonhos) ?? [];
      
      final sonhos = sonhosJson
          .map((json) => Sonho.fromJson(jsonDecode(json)))
          .toList();
      
      sonhos.removeWhere((s) => s.id == id);
      
      final sonhosAtualizadosJson = sonhos
          .map((s) => jsonEncode(s.toJson()))
          .toList();
      
      return await prefs.setStringList(_chaveSonhos, sonhosAtualizadosJson);
    } catch (e) {
      debugPrint('Erro ao excluir sonho: $e');
      return false;
    }
  }
}