import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/cartao_sonho.dart';
import '../modelos/sonho.dart';
import '../servicos/servico_api_cloudflare.dart';
import '../app_tema.dart';
import 'tela_detalhes_sonho.dart';
import 'tela_entrada_sonho.dart';

class TelaListaSonhos extends StatefulWidget {
  const TelaListaSonhos({Key? key}) : super(key: key);

  @override
  State<TelaListaSonhos> createState() => _TelaListaSonhosState();
}

class _TelaListaSonhosState extends State<TelaListaSonhos> {
  late Future<List<Sonho>> _sonhosFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarSonhos();
  }

  Future<void> _carregarSonhos() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
    _sonhosFuture = apiService.obterSonhos();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _navegarParaEntradaSonho() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaEntradaSonho()),
    );

    if (resultado == true) {
      _carregarSonhos();
    }
  }

  void _navegarParaDetalhesSonho(Sonho sonho) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaDetalhesSonho(sonho: sonho)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Sonhos'),
        backgroundColor: AppTema.corPrimaria,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Sonho>>(
              future: _sonhosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTema.corSecundaria,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Algo deu errado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTema.corTextoDimmed),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _carregarSonhos,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final sonhos = snapshot.data ?? [];

                if (sonhos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.nightlight_outlined,
                          color: AppTema.corSecundaria,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum sonho por trás das cortinas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toque no botão abaixo para registrar seu primeiro sonho',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTema.corTextoDimmed),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _navegarParaEntradaSonho,
                          child: const Text('Adicionar Sonho'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _carregarSonhos,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: sonhos.length,
                      itemBuilder: (context, index) {
                        final sonho = sonhos[index];
                        return CartaoSonho(
                          sonho: sonho,
                          aoClicar: () => _navegarParaDetalhesSonho(sonho),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaEntradaSonho,
        backgroundColor: AppTema.corSecundaria,
        child: const Icon(Icons.add),
      ),
    );
  }
} 