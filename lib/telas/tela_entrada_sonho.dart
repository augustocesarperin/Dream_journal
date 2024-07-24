import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../componentes/botao_lynchiano.dart';
import '../componentes/campo_texto_lynchiano.dart';
import '../servicos/servico_api_cloudflare.dart';
import '../app_tema.dart';
import '../modelos/sonho.dart';

class TelaEntradaSonho extends StatefulWidget {
  const TelaEntradaSonho({Key? key}) : super(key: key);

  @override
  State<TelaEntradaSonho> createState() => _TelaEntradaSonhoState();
}

class _TelaEntradaSonhoState extends State<TelaEntradaSonho> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _interpretacao;
  bool _interpretacaoGerada = false;
  String? _erro;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _gerarInterpretacao() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _interpretacao = null;
      _interpretacaoGerada = false;
      _erro = null;
    });

    try {
      debugPrint('Iniciando interpretação do sonho...');
      
      final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
      final interpretacao = await apiService.obterInterpretacao(_descricaoController.text);
      debugPrint('Interpretação recebida: $interpretacao');

      
      if (interpretacao.contains('temporariamente indisponível') || 
          interpretacao.contains('enfrentando dificuldades') ||
          interpretacao.contains('As cortinas vermelhas se fecharam temporariamente') ||
          interpretacao.contains('Não foi possível')) {
        
        setState(() {
          _erro = interpretacao;
          _interpretacao = null;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(interpretacao),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: _gerarInterpretacao,
              ),
            ),
          );
        }
        
        return;
      }

      FocusScope.of(context).unfocus();

      setState(() {
        _interpretacao = interpretacao;
        _interpretacaoGerada = true;
        _isLoading = false;
      });

      _scrollToBottom();

    } catch (e) {
      debugPrint('Erro ao gerar interpretação: $e');
      
      final mensagemErro = e.toString().contains('Exception:') 
          ? e.toString().split('Exception: ').last 
          : e.toString();
      
      FocusScope.of(context).unfocus();
      
      setState(() {
        _erro = mensagemErro;
        _interpretacao = null;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível interpretar seu sonho: ${mensagemErro.split(': ').last}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tentar Novamente',
              textColor: Colors.white,
              onPressed: _gerarInterpretacao,
            ),
          ),
        );
      }
    }
  }

  Future<void> _salvarSonho() async {
    if (_formKey.currentState?.validate() != true || _interpretacao == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Salvando sonho...');
      final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
      
      final novoSonho = Sonho(
        id: Uuid().v4(),  
        titulo: _tituloController.text.isEmpty ? "Sonho sem título" : _tituloController.text,
        descricao: _descricaoController.text,
        interpretacao: _interpretacao ?? '',
        dataCriacao: DateTime.now(),
      );
      
      final resultado = await apiService.salvarSonho(novoSonho);

      setState(() {
        _isLoading = false;
      });

      if (resultado && mounted) {
        debugPrint('Sonho salvo com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Seu sonho foi salvo",
              style: TextStyle(color: AppTema.corTexto),
            ),
            backgroundColor: AppTema.corAcento,
          ),
        );
        
        Navigator.pop(context, true);
      } else {
        throw Exception('Falha ao salvar o sonho');
      }
    } catch (e) {
      debugPrint('Erro ao salvar sonho: $e');
      setState(() {
        _isLoading = false;
        _erro = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar seu sonho: $_erro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Sonho'),
        backgroundColor: AppTema.corPrimaria,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampoTextoLynchiano(
                  rotulo: 'Título',
                  dica: 'Digite um título para o sonho (opcional)',
                  controlador: _tituloController,
                  validador: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CampoTextoLynchiano(
                  rotulo: 'Descreva o seu sonho',
                  dica: 'Descreva seu sonho em detalhes...',
                  controlador: _descricaoController,
                  isMultiline: true,
                  validador: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, descreva seu sonho';
                    }
                    if (value.length < 10) {
                      return 'A descrição deve ter pelo menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quanto mais detalhes você fornecer, melhor será a interpretação.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTema.corTextoDimmed,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                BotaoLynchiano(
                  texto: 'Interpretar Sonho',
                  aoClicar: _gerarInterpretacao,
                  isEnabled: !(_isLoading && _interpretacaoGerada),
                  isLoading: _isLoading && !_interpretacaoGerada,
                ),
                if (_isLoading && !_interpretacaoGerada) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        Text(
                          'Aguarde enquanto a cortina vermelha se abre',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppTema.corTextoDimmed,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Isso pode levar alguns segundos',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTema.corTextoDimmed,
                          ),
                        ),
                      ],
                    ), 
                  ),
                ],
                if (_erro != null && _interpretacao == null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Erro na interpretação',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _erro!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_interpretacao != null) ...[
                  const SizedBox(height: 32),
                  const Center(
                    child: Icon(
                      Icons.nightlight_outlined,
                      color: AppTema.corSecundaria,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTema.corAcento.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTema.corAcento),
                    ),
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Text(
                        _interpretacao!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: AppTema.corTexto,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BotaoLynchiano(
                    texto: 'Salvar Sonho',
                    aoClicar: _salvarSonho,
                    isEnabled: _interpretacao != null,
                    isLoading: _isLoading && _interpretacaoGerada,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 