import 'package:flutter/material.dart';
import 'partido_individual.dart';
import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';
import '../mock/mock_data.dart';

class PartidosPage extends StatelessWidget {
  const PartidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Partidos",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.tune, color: Color(0xFFCC3A00)),
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

          Expanded(
            child: ListView.builder(
              itemCount: partidosMock.length,
              itemBuilder: (context, index) {
                final partido = partidosMock[index];
                final sigla = partido["sigla"] as String;
                final nome = partido["nome"] as String;

                final qtdVereadores = vereadoresMock
                    .where((v) => v["partido"] as String == sigla)
                    .length;

                final nomesVereadores = vereadoresMock
                    .where((v) => v["partido"] as String == sigla)
                    .map((v) => v["nome"] as String)
                    .toSet();

                final qtdProjetos = projetosMock
                    .where((p) => (p["autoria"] as List)
                        .any((autor) => nomesVereadores.contains(autor)))
                    .length;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PartidoIndividualPage(partido: partido),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
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
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              sigla,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sigla,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(nome),
                              const SizedBox(height: 8),
                              Text(
                                "$qtdProjetos projetos   $qtdVereadores vereadores",
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

      bottomNavigationBar: const Rodape(paginaAtual: 2),
    );
  }
}

