import 'package:flutter/material.dart';
import '../modelos/sonho.dart';
import '../app_tema.dart';

class CartaoSonho extends StatelessWidget {
  final Sonho sonho;
  final VoidCallback aoClicar;

  const CartaoSonho({
    Key? key,
    required this.sonho,
    required this.aoClicar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 4,
      shadowColor: AppTema.corAcento.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTema.corAcento, width: 1),
      ),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sonho.titulo,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTema.corTexto,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTema.corAcento.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatarData(sonho.dataCriacao),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTema.corTextoDimmed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: AppTema.corAcento, height: 1),
              const SizedBox(height: 12),
              Text(
                sonho.descricao,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                   color: AppTema.corTextoDimmed,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTema.corPrimaria.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTema.corAcento.withOpacity(0.3)),
                ),
                child: Text(
                  sonho.interpretacao,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTema.corTexto,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Toque para ver mais',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
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