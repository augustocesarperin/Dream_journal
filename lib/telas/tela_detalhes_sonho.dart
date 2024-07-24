import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/sonho.dart';
import '../app_tema.dart';
import '../servicos/servico_api_cloudflare.dart';

class TelaDetalhesSonho extends StatelessWidget {
  final Sonho sonho;

  const TelaDetalhesSonho({
    Key? key,
    required this.sonho,
  }) : super(key: key);

  Future<void> _deletarSonho(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja deletar este sonho permanentemente?'),
          backgroundColor: AppTema.corFundo,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Deletar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      try {
        final sucesso = await apiService.excluirSonho(sonho.id);
        if (sucesso && context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text(
                "O sonho foi apagado do aplicativo, mas permanece em seu inconsciente.",
                style: TextStyle(color: AppTema.corTexto),
              ),
              backgroundColor: AppTema.corAcento,
            ),
          );
          navigator.pop(true);
        } else if (!sucesso) {
          throw Exception('Falha ao deletar o sonho do armazenamento.');
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar sonho: ${e.toString()}'),
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
        title: const Text('Detalhes do Sonho'),
        backgroundColor: AppTema.corPrimaria,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Deletar Sonho',
            onPressed: () => _deletarSonho(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sonho.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTema.corTexto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatarData(sonho.dataCriacao),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTema.corTextoDimmed,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Descrição',
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
                ),
                child: Text(
                  sonho.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTema.corTexto,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                    sonho.interpretacao,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: AppTema.corTexto,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
} 