import 'package:flutter/material.dart';
import '../app_tema.dart';

class TelaSobreApp extends StatelessWidget {
  const TelaSobreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define text styles based on AppTema for consistency
    final tituloStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: AppTema.corSecundaria,
      height: 1.4,
    );
    final paragrafoStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: AppTema.corTexto,
    );
     final devStyle = TextStyle(
      fontSize: 14,
      color: AppTema.corTextoDimmed,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: AppTema.corPrimaria,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- Block 1: Life vs Dreams ---
                  Card(
                    elevation: 2.0, // Subtle shadow
                    margin: const EdgeInsets.only(bottom: 24.0), // Space below card
                    color: AppTema.corPrimaria.withOpacity(0.5), // Subtle background
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text.rich(
                              TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'Vivemos tentando organizar a vida.\n'),
                                  TextSpan(text: 'Colocar ordem no caos.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                              TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'Mas o sonho devolve a vida ao seu estado natural:\n'),
                                  TextSpan(text: 'estranho, abstrato, '),
                                  TextSpan(text: 'cheio de imagens que não obedecem.', style: TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                               TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'E talvez seja essa a sua função:\n'),
                                  TextSpan(text: 'nos ajudar a lidar com o '),
                                  TextSpan(text: 'absurdo da vida.', style: TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                         ],
                      ),
                    ),
                  ),

                  // --- Block 2: Dream Journal Role ---
                  Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(bottom: 24.0),
                    color: AppTema.corPrimaria.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text.rich(
                        TextSpan(
                          style: paragrafoStyle,
                          children: <TextSpan>[
                            TextSpan(text: 'O Dream Journal é um espaço íntimo\n'),
                            TextSpan(text: 'para registrar essas experiências e, se quiser,\n'),
                            TextSpan(text: 'se aproximar delas com o auxílio de um intérprete\n'),
                            TextSpan(text: 'que propõe leituras simbólicas e psicanalíticas.'),
                          ],
                        ),
                        textAlign: TextAlign.center, 
                      ),
                    ),
                  ),

                  // --- Block 3: Writing & Therapy ---
                  Card(
                     elevation: 2.0,
                     margin: const EdgeInsets.only(bottom: 24.0),
                     color: AppTema.corPrimaria.withOpacity(0.5),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                     child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text.rich(
                               TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'Não se trata de substituir o processo terapêutico.\n'),
                                  TextSpan(text: 'Mas de reconhecer que, às vezes,\n'),
                                  TextSpan(text: 'o primeiro passo é simplesmente '),
                                  TextSpan(text: 'não esquecer.', style: TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                               TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'Escrever pode ser isso:\n'),
                                  TextSpan(text: 'um jeito de continuar sonhando acordado,\n'),
                                  TextSpan(text: 'de deixar o sonho ecoar um pouco mais.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                               TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'E para alguns, quem sabe,\n'),
                                  TextSpan(text: 'esse gesto possa abrir caminho para algo maior:\n'),
                                  TextSpan(text: 'uma escuta mais profunda,\n'),
                                  TextSpan(text: 'uma conversa que segue em outro lugar.'),
                                ],
                              ),
                            ),
                         ],
                       ),
                    ),
                  ),

                  // --- Block 4: Traces & Following ---
                   Card(
                     elevation: 2.0,
                     margin: const EdgeInsets.only(bottom: 24.0),
                     color: AppTema.corPrimaria.withOpacity(0.5),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                     child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text.rich(
                               TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                   TextSpan(text: 'Alguns sonhos voltam, outros não.\n'),
                                   TextSpan(text: 'Alguns parecem vazios, outros carregam um peso que não se explica.\n'),
                                   TextSpan(text: 'Mas todos deixam rastros.'),
                                 ],
                               ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                              TextSpan(
                                style: paragrafoStyle,
                                children: <TextSpan>[
                                  TextSpan(text: 'E escrever é uma forma de segui-los,\n'),
                                  TextSpan(text: 'mesmo sem saber pra onde vão.'),
                                ],
                              ),
                            ),
                         ],
                       ),
                     ),
                   ),

                  const SizedBox(height: 20), // Final spacing before end

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 