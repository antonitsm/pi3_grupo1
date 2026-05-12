import 'package:flutter/material.dart';
import 'partido_individual.dart';
import 'projetos.dart';
import 'vereadores.dart';

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
      backgroundColor: Colors.grey[200],

      // HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          '🏛️',
          style: TextStyle(color: Colors.red),
        ),
      ),

      body: Column(
        children: [
          // Título + Busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  size: 28,
                  color: Colors.brown,
                ),

                const SizedBox(width: 10),

                const Text(
                  "Partidos",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: "Buscar",
                    ),
                  ),
                )
              ],
            ),
          ),

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,

        onTap: (index) {
          // PROJETOS
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProjetosPage(),
              ),
            );
          }

          // VEREADORES
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VereadoresPage(),
              ),
            );
          }
        },

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

// CARD DE PARTIDO
class PartidoCard extends StatelessWidget {
  const PartidoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PartidoIndividualPage(),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        padding: const EdgeInsets.all(12),

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

        child: Row(
          children: [
            // LOGO
            Container(
              width: 60,
              height: 60,
              color: Colors.blueGrey,
            ),

            const SizedBox(width: 12),

            // TEXTOS
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sigla partido",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Text("Nome do partido"),

                SizedBox(height: 6),

                Text("X projetos   X vereadores"),
              ],
            )
          ],
        ),
      ),
    );
  }
}