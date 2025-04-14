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
  
  bool _isLoading = false;
  String? _interpretacao;
  bool _interpretacaoGerada = false;
  String? _erro;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _gerarInterpretacao() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
      _interpretacao = null;
      _interpretacaoGerada = false;
      _erro = null;
    });

    try {
      debugPrint('Iniciando interpretação do sonho...');
      
      // Mostrar feedback visual para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interpretando seu sonho... Isso pode levar alguns segundos.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
      final interpretacao = await apiService.obterInterpretacao(_descricaoController.text);
      debugPrint('Interpretação recebida: $interpretacao');

      // Verificar se a interpretação contém uma mensagem de erro ou indisponibilidade
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

      setState(() {
        _interpretacao = interpretacao;
        _interpretacaoGerada = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao gerar interpretação: $e');
      
      final mensagemErro = e.toString().contains('Exception:') 
          ? e.toString().split('Exception: ').last 
          : e.toString();
      
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
      
      // Cria um objeto Sonho com os dados do formulário
      final novoSonho = Sonho(
        id: Uuid().v4(),  // ID vazio para novo sonho
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        interpretacao: _interpretacao ?? '',
        dataCriacao: DateTime.now(),
      );
      
      // Chama o método atualizado
      final resultado = await apiService.salvarSonho(novoSonho);

      setState(() {
        _isLoading = false;
      });

      if (resultado && mounted) {
        debugPrint('Sonho salvo com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sonho salvo com sucesso!'),
            backgroundColor: Colors.green,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampoTextoLynchiano(
                  rotulo: 'Data',
                  dica: 'Digite a data do sonho (opcional)',
                  controlador: _tituloController,
                  validador: (value) {
                    // Campo não obrigatório
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
                  isLoading: _isLoading && !_interpretacaoGerada,
                ),
                if (_isLoading && !_interpretacaoGerada) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppTema.corSecundaria,
                        ),
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
                  const Text(
                    'Interpretação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTema.corSecundaria,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTema.corPrimaria,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTema.corAcento),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
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
                  Row(
                    children: [
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Salvar Sonho',
                          aoClicar: _salvarSonho,
                          isLoading: _isLoading && _interpretacaoGerada,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Deletar Sonho',
                          aoClicar: () {
                            // Mostra um diálogo de confirmação
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar exclusão'),
                                  content: const Text('Tem certeza que deseja deletar este sonho?'),
                                  backgroundColor: AppTema.corFundo,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text(
                                        'Deletar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          isOutlined: true,
                        ),
                      ),
                    ],
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