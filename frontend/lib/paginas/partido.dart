import 'package:flutter/material.dart';
import 'partido_individual.dart';
import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PartidosPage(),
    );
  }
}

class PartidosPage extends StatelessWidget {
  const PartidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // HEADER
      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // TÍTULO
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
              itemCount: 5,
              itemBuilder: (context, index) {
                return const PartidoCard();
              },
            ),
          ),
        ],
      ),

      // FOOTER
      bottomNavigationBar: const Rodape(
        paginaAtual: 2,
      ),
    );
  }
}

// CARD
class PartidoCard extends StatelessWidget {
  const PartidoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PartidoIndividualPage(),
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

          borderRadius:
              BorderRadius.circular(16),

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
            // LOGO
            Container(
              width: 60,
              height: 60,

              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Sigla partido",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Nome do partido",
                  ),

                  SizedBox(height: 8),

                  Text(
                    "X projetos   X vereadores",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}