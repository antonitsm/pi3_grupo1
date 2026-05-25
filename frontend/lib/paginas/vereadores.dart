import 'package:flutter/material.dart';
import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';

import 'vereador_individual.dart';

// 🔸 MODEL
class Vereador {
  final String nome;
  final String partido;
  final int projetos;

  Vereador({
    required this.nome,
    required this.partido,
    required this.projetos,
  });
}

class VereadoresPage extends StatelessWidget {
  VereadoresPage({super.key});

  final List<Vereador> vereadores = List.generate(
    5,
    (index) => Vereador(
      nome: "Nome do vereador",
      partido: "Sigla partido",
      projetos: 10 + index,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: ListView.builder(
        itemCount: vereadores.length,

        itemBuilder: (context, index) {
          final v = vereadores[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VereadorIndividualPage(
                    vereador: v,
                  ),
                ),
              );
            },

            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFED5523),
                  width: 2,
                ),
              ),

              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black,
                  ),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        v.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(v.partido),

                      Text("${v.projetos} projetos"),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: const Rodape(
        paginaAtual: 1,
      ),
    );
  }
}