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
      projetos: 10 + index,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),

      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // TÍTULO
          const Text(
            "Vereadores",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 28),

          // FILTRO + BUSCA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.tune,
                  color: Color(0xFFFF5A1F),
                  size: 30,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    height: 52,

                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),

                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),

                        hintText: "Buscar",

                        border: InputBorder.none,

                        contentPadding:
                            EdgeInsets.symmetric(
                          vertical: 14,
                        ),
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
                      color: Colors.grey[300],

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