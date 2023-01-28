import 'package:flutter/material.dart';
import '../app_tema.dart';

class CampoTextoLynchiano extends StatelessWidget {
  final String rotulo;
  final String? dica;
  final TextEditingController controlador;
  final bool isMultiline;
  final bool isObscured;
  final TextInputType? tipoTeclado;
  final String? Function(String?)? validador;

  const CampoTextoLynchiano({
    Key? key,
    required this.rotulo,
    this.dica,
    required this.controlador,
    this.isMultiline = false,
    this.isObscured = false,
    this.tipoTeclado,
    this.validador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            color: AppTema.corTexto,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controlador,
          obscureText: isObscured,
          keyboardType: tipoTeclado ?? (isMultiline ? TextInputType.multiline : TextInputType.text),
          maxLines: isMultiline ? 5 : 1,
          validator: validador,
          style: const TextStyle(color: AppTema.corTexto),
          decoration: InputDecoration(
            hintText: dica,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTema.corPrimaria),
            ),
          ),
        ),
      ],
    );
  }
} 