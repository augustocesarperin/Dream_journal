import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/sonho.dart';
import '../app_tema.dart';
import '../servicos/servico_api_cloudflare.dart';
import './tela_entrada_sonho.dart'; // Import needed for navigation

// Convert to StatefulWidget
class TelaDetalhesSonho extends StatefulWidget {
  final Sonho sonhoInicial;

  const TelaDetalhesSonho({
    Key? key,
    required this.sonhoInicial,
  }) : super(key: key);

  @override
  State<TelaDetalhesSonho> createState() => _TelaDetalhesSonhoState();
}

class _TelaDetalhesSonhoState extends State<TelaDetalhesSonho> {
  late Sonho _sonhoAtual;

  @override
  void initState() {
    super.initState();
    _sonhoAtual = widget.sonhoInicial;
  }

  Future<void> _deletarSonho(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final apiService = Provider.of<ServicoApiCloudflare>(context, listen: false);

    // Show confirmation dialog
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

    // Proceed with deletion if confirmed
    if (confirmado == true) {
      try {
        // Use the ID from the current state dream
        final sucesso = await apiService.excluirSonho(_sonhoAtual.id);
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
          // Pop with true to indicate deletion happened
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

  // Navigation function for editing
  Future<void> _navegarParaEdicao() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEntradaSonho(sonhoParaEditar: _sonhoAtual),
      ),
    );

    // If the edit screen popped with a Sonho object (meaning edit was successful)
    if (resultado is Sonho && mounted) {
      setState(() {
        // Update the local state with the returned, updated dream object
        _sonhoAtual = resultado;
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text("Detalhes do sonho atualizados.", style: TextStyle(color: AppTema.corTexto)),
          backgroundColor: AppTema.corAcento,
        ),
      );
    } else if (resultado == true) {
       // This case might happen if we came from creating a new dream, 
       // although typically this screen is pushed only for existing dreams.
       // Might need to refresh from parent in this scenario if it occurs.
       debugPrint("TelaDetalhesSonho received 'true' after navigation. This might indicate an issue if editing.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use _sonhoAtual from state to build the UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Sonho'),
        backgroundColor: AppTema.corPrimaria,
        actions: [
          // Add Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined), // Using outlined icon
            tooltip: 'Editar Sonho',
            onPressed: _navegarParaEdicao, // Call the navigation function
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Deletar Sonho',
            // Pass context explicitly if needed, or ensure it's available
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
              // Use _sonhoAtual for display
              Text(
                _sonhoAtual.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTema.corTexto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatarData(_sonhoAtual.dataCriacao),
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
                width: double.infinity, // Ensure container takes full width
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTema.corPrimaria,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _sonhoAtual.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTema.corTexto,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Display interpretation section ONLY if interpretation exists
              if (_sonhoAtual.interpretacao != null && _sonhoAtual.interpretacao!.isNotEmpty) ...[
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
                  width: double.infinity, 
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTema.corPrimaria,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTema.corAcento),
                  ),
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Text(
                      _sonhoAtual.interpretacao!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: AppTema.corTexto,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Add spacing after interpretation
              ]
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    // Consider using the intl package for more robust date formatting
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
} 