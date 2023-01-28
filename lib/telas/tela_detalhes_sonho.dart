import 'package:flutter/material.dart';
import '../modelos/sonho.dart';
import '../app_tema.dart';

class TelaDetalhesSonho extends StatelessWidget {
  final Sonho sonho;

  const TelaDetalhesSonho({
    Key? key,
    required this.sonho,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Sonho'),
        backgroundColor: AppTema.corPrimaria,
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
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '"Em sonhos, você vê o que seu coração esconde."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTema.corTextoDimmed,
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