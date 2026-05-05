import 'package:flutter/material.dart';

class PartidoIndividualPage extends StatelessWidget {
  const PartidoIndividualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🏛️',
          style: TextStyle(color: Colors.red),
        ),
      ),

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
                    color: Colors.brown,
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
                color: Colors.orange[200],
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
                      backgroundColor: Colors.deepOrange,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: "Projetos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Vereadores",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Partidos",
          ),
        ],
      ),
    );
  }
}