import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'servicos/servico_api_cloudflare.dart';
import 'app_tema.dart';
import 'telas/tela_lista_sonhos.dart';

class DreamJournalApp extends StatelessWidget {
  const DreamJournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ServicoApiCloudflare>(
          create: (_) => ServicoApiCloudflare(),
        ),
      ],
      child: MaterialApp(
        title: 'Dream Journal',
        theme: AppTema.obterTema(),
        debugShowCheckedModeBanner: false,
        home: const TelaListaSonhos(),
      ),
    );
  }
} 