import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../componentes/botao_lynchiano.dart';
import '../componentes/campo_texto_lynchiano.dart';
import '../servicos/servico_api_cloudflare.dart';
import '../app_tema.dart';
import '../modelos/sonho.dart';

class TelaEntradaSonho extends StatefulWidget {
  final Sonho? sonhoParaEditar;

  const TelaEntradaSonho({Key? key, this.sonhoParaEditar}) : super(key: key);

  @override
  State<TelaEntradaSonho> createState() => _TelaEntradaSonhoState();
}

class _TelaEntradaSonhoState extends State<TelaEntradaSonho> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoadingInterpretacao = false;
  bool _isLoadingSalvamento = false;
  String? _interpretacao;
  String? _erro;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    if (widget.sonhoParaEditar != null) {
      _tituloController.text = widget.sonhoParaEditar!.titulo == "Sonho sem título" 
          ? '' 
          : widget.sonhoParaEditar!.titulo;
      _descricaoController.text = widget.sonhoParaEditar!.descricao;
      if (widget.sonhoParaEditar!.interpretacao != null && widget.sonhoParaEditar!.interpretacao!.isNotEmpty) {
        _interpretacao = widget.sonhoParaEditar!.interpretacao;
      }
    }

    _descricaoController.addListener(_checkFormValidity);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormValidity());
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.removeListener(_checkFormValidity);
    _descricaoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (mounted && _isFormValid != isValid) {
        setState(() {
          _isFormValid = isValid;
        });
      }
    });
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
    if (!_isFormValid || _isLoadingInterpretacao || _isLoadingSalvamento) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoadingInterpretacao = true;
      _interpretacao = null;
      _erro = null;
    });

    try {
      debugPrint('Iniciando interpretação do sonho...');
      final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);
      final resultInterpretation = await apiService.obterInterpretacao(_descricaoController.text);
      debugPrint('Interpretação recebida: $resultInterpretation');

      if (resultInterpretation.contains('temporariamente indisponível') ||
          resultInterpretation.contains('enfrentando dificuldades') ||
          resultInterpretation.contains('As cortinas vermelhas se fecharam temporariamente') ||
          resultInterpretation.contains('Não foi possível')) {
         if (mounted) {
             setState(() {
               _erro = resultInterpretation;
               _interpretacao = null;
             });
         }

        return;
      }

      if (mounted) {
        setState(() {
          _interpretacao = resultInterpretation;
          _erro = null;
        });
        _scrollToBottom();
      }

    } catch (e) {
      debugPrint('Erro ao gerar interpretação: $e');
      final mensagemErro = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ').last
          : e.toString();
      if (mounted) {
        setState(() {
          _erro = mensagemErro;
          _interpretacao = null;
        });
      }
    } finally {
       if (mounted) {
          setState(() { _isLoadingInterpretacao = false; });
       }
    }
  }

  Future<void> _salvarSonho() async {
    if (!_isFormValid || _isLoadingInterpretacao || _isLoadingSalvamento) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoadingSalvamento = true;
      _erro = null;
    });

    try {
      debugPrint('Salvando sonho (Editando: ${widget.sonhoParaEditar != null})...');
      final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);

      final sonhoParaSalvar = Sonho(
        id: widget.sonhoParaEditar?.id ?? const Uuid().v4(),
        titulo: _tituloController.text.trim().isEmpty ? "Sonho sem título" : _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        interpretacao: _interpretacao ?? '',
        dataCriacao: widget.sonhoParaEditar?.dataCriacao ?? DateTime.now(),
      );

      final resultado = await apiService.salvarSonho(sonhoParaSalvar);

      if (resultado && mounted) {
        debugPrint('Sonho salvo com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.sonhoParaEditar == null ? "Seu sonho foi salvo" : "Sonho atualizado",
              style: const TextStyle(color: AppTema.corTexto),
            ),
            backgroundColor: AppTema.corAcento,
          ),
        );
        Navigator.pop(context, widget.sonhoParaEditar == null ? true : sonhoParaSalvar);
      } else if (!resultado) {
        throw Exception('Falha ao salvar o sonho no armazenamento local.');
      }
    } catch (e) {
      debugPrint('Erro ao salvar sonho: $e');
      final mensagemErro = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ').last
          : e.toString();
      if (mounted){
          setState(() {
              _erro = mensagemErro;
          });
      }

    } finally {
       if (mounted) {
         setState(() {
            _isLoadingSalvamento = false;
         });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.sonhoParaEditar == null ? 'Novo Sonho' : 'Editar Sonho';

    // --- DEBUG PRINTS --- 
    print('--- Build TelaEntradaSonho ---');
    print('sonhoParaEditar: ${widget.sonhoParaEditar?.id ?? 'null'}');
    print('_isFormValid: $_isFormValid');
    print('_interpretacao: ${_interpretacao?.substring(0, (_interpretacao?.length ?? 0) > 20 ? 20 : _interpretacao?.length)}...');
    print('_erro: $_erro');
    print('_isLoadingInterpretacao: $_isLoadingInterpretacao');
    print('_isLoadingSalvamento: $_isLoadingSalvamento');
    // --- END DEBUG PRINTS ---

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: AppTema.corPrimaria,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            onChanged: _checkFormValidity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTextoLynchiano(
                  rotulo: 'Título',
                  dica: 'Um título para seu sonho (opcional)',
                  controlador: _tituloController,
                ),
                const SizedBox(height: 20),
                CampoTextoLynchiano(
                  rotulo: 'Descreva o seu sonho *',
                  dica: 'Descreva seu sonho em detalhes...',
                  controlador: _descricaoController,
                  isMultiline: true,
                  validador: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A descrição é obrigatória';
                    }
                    if (value.length < 10) {
                      return 'Descreva com pelo menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quanto mais detalhes, melhor a interpretação.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTema.corTextoDimmed,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                if (_interpretacao == null)
                  Row(
                    children: [
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Interpretar',
                          aoClicar: _gerarInterpretacao,
                          isEnabled: _isFormValid && !_isLoadingInterpretacao && !_isLoadingSalvamento,
                          isLoading: _isLoadingInterpretacao,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Salvar Sonho',
                          aoClicar: _salvarSonho,
                          isEnabled: _isFormValid && !_isLoadingInterpretacao && !_isLoadingSalvamento,
                          isLoading: _isLoadingSalvamento,
                        ),
                      ),
                    ],
                  ),

                if (_erro != null && !_isLoadingInterpretacao && !_isLoadingSalvamento) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTema.corAcento.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTema.corSecundaria.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppTema.corSecundaria, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Ocorreu um Erro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTema.corSecundaria,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _erro!,
                          style: TextStyle(
                            color: AppTema.corTexto.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_interpretacao != null && _erro == null) ...[
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
                    width: double.infinity,
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
                  Row(
                    children: [
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Reinterpretar',
                          aoClicar: _gerarInterpretacao,
                          isEnabled: (){
                            final enabled = _isFormValid && !_isLoadingInterpretacao && !_isLoadingSalvamento;
                            print('Reinterpretar Button isEnabled: $enabled (form: $_isFormValid, loadInt: $_isLoadingInterpretacao, loadSave: $_isLoadingSalvamento)');
                            return enabled;
                          }(),
                          isLoading: _isLoadingInterpretacao,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BotaoLynchiano(
                          texto: 'Salvar Sonho',
                          aoClicar: _salvarSonho,
                          isEnabled: (){
                            final enabled = _isFormValid && !_isLoadingInterpretacao && !_isLoadingSalvamento;
                            print('Salvar Button isEnabled: $enabled (form: $_isFormValid, loadInt: $_isLoadingInterpretacao, loadSave: $_isLoadingSalvamento)');
                            return enabled;
                          }(),
                          isLoading: _isLoadingSalvamento,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 