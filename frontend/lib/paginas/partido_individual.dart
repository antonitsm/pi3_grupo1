import 'package:flutter/material.dart';
import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';

class PartidoIndividualPage extends StatelessWidget {
  const PartidoIndividualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // SIGLA
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sigla",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC33505),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CARD PRINCIPAL
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF67F57),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Nome do partido",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text("Sigla partido"),
                  Text("Desde de {ano}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // VEREADORES
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "XX vereadores na câmara",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC3A00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Conferir nomes"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TÍTULO PROJETOS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confira os projetos de lei do Partido XXX:",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CARROSSEL SIMPLES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back_ios),

                Container(
                  width: 220,
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 3),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text("Nome projeto de lei postado"),
                  ),
                ),

                const Icon(Icons.arrow_forward_ios),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // FOOTER
      bottomNavigationBar: const Rodape(
        paginaAtual: 2,
      ),
    );
  }
}