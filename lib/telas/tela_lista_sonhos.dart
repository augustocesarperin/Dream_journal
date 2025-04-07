import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/cartao_sonho.dart';
import '../modelos/sonho.dart';
import '../servicos/servico_api_cloudflare.dart';
import '../app_tema.dart';
import 'tela_detalhes_sonho.dart';
import 'tela_entrada_sonho.dart';
import './tela_sobre_app.dart';

class TelaListaSonhos extends StatefulWidget {
  const TelaListaSonhos({Key? key}) : super(key: key);

  @override
  State<TelaListaSonhos> createState() => _TelaListaSonhosState();
}

class _TelaListaSonhosState extends State<TelaListaSonhos> {
  late Future<List<Sonho>> _sonhosFuture;
  bool _isLoading = false;
  bool _isListEmpty = true;

  @override
  void initState() {
    super.initState();
    _carregarSonhos();
  }

  Future<void> _carregarSonhos() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
    _sonhosFuture = apiService.obterSonhos();

    try {
      await _sonhosFuture;
    } catch (_) {
      // Error is handled by FutureBuilder, just catch to proceed
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Future<void> _navegarParaDetalhesSonho(Sonho sonho) async {
    final bool? atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaDetalhesSonho(sonhoInicial: sonho)),
    );

    if (atualizado == true && mounted) {
      _carregarSonhos();
    }
  }

  void _navegarParaSobre() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaSobreApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTema.corPrimaria,
        title: const Text(
          'Dream Journal',
          style: TextStyle(
            color: AppTema.corTexto,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre o App',
            onPressed: _navegarParaSobre,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarSonhos,
        color: AppTema.corSecundaria,
        child: FutureBuilder<List<Sonho>>(
          future: _sonhosFuture,
          builder: (context, snapshot) {
            if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTema.corSecundaria));
            }

            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isListEmpty) {
                  setState(() { _isListEmpty = true; });
                }
              });
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
                      'Algo deu errado ao carregar os sonhos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        snapshot.error.toString().split('Exception: ').last,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTema.corTextoDimmed),
                      ),
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
            final currentlyEmpty = sonhos.isEmpty;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isListEmpty != currentlyEmpty) {
                setState(() { _isListEmpty = currentlyEmpty; });
              }
            });

            if (currentlyEmpty) {
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Toque no botão abaixo para registrar seu primeiro sonho',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTema.corTextoDimmed),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTema.corSecundaria,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      onPressed: _navegarParaEntradaSonho,
                      child: const Text('Adicionar Sonho'),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
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
              );
            }
          },
        ),
      ),
      floatingActionButton: _isListEmpty
          ? null
          : FloatingActionButton(
              onPressed: _navegarParaEntradaSonho,
              backgroundColor: AppTema.corSecundaria,
              foregroundColor: Colors.white,
              tooltip: 'Adicionar Sonho',
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: Container(
        height: 55,
        color: AppTema.corPrimaria.withOpacity(0.1),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\u00A9 Abstratus Labs',
                style: TextStyle(
                  color: AppTema.corTextoDimmed,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'augustocesarperin@abstratuslabs.com',
                style: TextStyle(
                  color: AppTema.corTextoDimmed,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}