import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

// Ponto de entrada do aplicativo
// Inicializa o ambiente e configurações
void main() async {
  // Inicializa o binding do Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as variáveis de ambiente do .env
  // Se falhar, usa os valores padrão
  try {
    await dotenv.load(fileName: '.env').timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('AVISO: Timeout ao carregar .env. Usando valores padrão.');
        throw Exception('Timeout ao carregar arquivo .env');
      },
    );
    
    final endpoint = dotenv.env['CLOUDFLARE_API_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      // Endpoint padrão para a API
      dotenv.env['CLOUDFLARE_API_ENDPOINT'] = 'https://dreamlynch2.gutoperin.workers.dev/';
    }
  } catch (e) {
    // Se der erro, usa o endpoint padrão - funciona na maioria dos casos
    dotenv.env['CLOUDFLARE_API_ENDPOINT'] = 'https://dreamlynch2.gutoperin.workers.dev/';
  }
  
  // Configura o tratamento de erros não capturados
  // Isso ajuda a debugar problemas em produção
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Erro não capturado: ${details.exception}');
  };
  
  // Inicia o app!
  runApp(const DreamJournalApp());
}
