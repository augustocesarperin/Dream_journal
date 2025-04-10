import 'package:flutter/material.dart';
import '../app_tema.dart';

class BotaoLynchiano extends StatelessWidget {
  final String texto;
  final VoidCallback? aoClicar;
  final bool isLoading;
  final bool isEnabled;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const BotaoLynchiano({
    Key? key,
    required this.texto,
    required this.aoClicar,
    this.isLoading = false,
    this.isEnabled = true,
    this.isOutlined = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool effectivelyEnabled = isEnabled && !isLoading;

    final baseStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : AppTema.corSecundaria,
      foregroundColor: isOutlined ? AppTema.corSecundaria : Colors.white,
      side: isOutlined ? const BorderSide(color: AppTema.corSecundaria, width: 1.5) : null,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
      elevation: effectivelyEnabled ? 2 : 0,
    );

    final disabledStyle = baseStyle.copyWith(
      backgroundColor: MaterialStateProperty.all(AppTema.corPrimaria.withOpacity(0.5)),
      foregroundColor: MaterialStateProperty.all(AppTema.corTextoDimmed.withOpacity(0.7)),
      side: isOutlined ? MaterialStateProperty.all(BorderSide(color: AppTema.corTextoDimmed.withOpacity(0.5), width: 1.5)) : null,
    );

    return ElevatedButton(
      onPressed: effectivelyEnabled ? aoClicar : null,
      style: effectivelyEnabled ? baseStyle : disabledStyle,
      child: isLoading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isOutlined ? AppTema.corSecundaria : Colors.white.withOpacity(0.8),
              ),
            )
          : Text(texto),
    );
  }
} 