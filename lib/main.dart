import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      dotenv.env['CLOUDFLARE_API_ENDPOINT'] = 'https://dreamlynch2.gutoperin.workers.dev/';
    }
  } catch (e) {
    // Definir valores padrão para as variáveis de ambiente
    dotenv.env['CLOUDFLARE_API_ENDPOINT'] = 'https://dreamlynch2.gutoperin.workers.dev/';
  }
  
  // Configurar tratamento de erros não capturados
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Erro não capturado: ${details.exception}');
  };
  
  runApp(const DreamJournalApp());
}
