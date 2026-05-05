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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PartidosPage(),
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
                const Icon(Icons.filter_list, size: 28, color: Colors.brown),
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

// CARD DE PARTIDO
class PartidoCard extends StatelessWidget {
  const PartidoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
    );
  }
}