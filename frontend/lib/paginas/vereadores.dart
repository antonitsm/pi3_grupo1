import 'package:flutter/material.dart';
import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import 'vereador_individual.dart';

// MODEL
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
      projetos: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // TÍTULO
          const Text(
            "Vereadores",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // FILTRO + BUSCA
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  Icon(Icons.tune, color: const Color(0xFFCC3A00)),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      height: 40,

                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // LISTA
          Expanded(
            child: ListView.builder(
              itemCount: vereadores.length,

              itemBuilder: (context, index) {
                final v = vereadores[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VereadorIndividualPage(
                          vereador: v,
                        ),
                      ),
                    );
                  },

                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border.all(
                        color: const Color(0xFFC33505),
                        width: 2),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),


                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.black,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                v.nome,

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                v.partido,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                "${v.projetos} projetos",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar:
          const Rodape(
        paginaAtual: 1,
      ),
    );
  }
}