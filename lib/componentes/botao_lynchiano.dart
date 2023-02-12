import 'package:flutter/material.dart';
import '../app_tema.dart';

// Widget personalizado para o botão com estilo visual do tema
// Suporta estado de carregamento e variante outline
class BotaoLynchiano extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;
  final bool isLoading;
  final bool isOutlined;
  // TODO: adicionar suporte a ícones nos botões

  const BotaoLynchiano({
    Key? key,
    required this.texto,
    required this.aoClicar,
    this.isLoading = false,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Botão de largura completa
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : aoClicar,
        style: isOutlined
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTema.corSecundaria,
                side: const BorderSide(color: AppTema.corSecundaria, width: 2),
              )
            : null, // usa o estilo padrão do tema
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white, // cor fixa, talvez melhorar depois
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
} 