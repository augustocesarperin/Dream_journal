import 'package:flutter/material.dart';
import '../app_tema.dart';

class BotaoLynchiano extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;
  final bool isLoading;
  final bool isOutlined;

  const BotaoLynchiano({
    Key? key,
    required this.texto,
    required this.aoClicar,
    this.isLoading = false,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            : null,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
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