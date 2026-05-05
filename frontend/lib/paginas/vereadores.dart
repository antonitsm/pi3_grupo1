import 'package:flutter/material.dart';
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
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Vereadores", style: TextStyle(color: Colors.black)),
        actions: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10)
        ],
      ),

      body: ListView.builder(
        itemCount: vereadores.length,
        itemBuilder: (context, index) {
          final v = vereadores[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VereadorIndividualPage(vereador: v),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 25, backgroundColor: Colors.black),
                  SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.nome, style: TextStyle(fontWeight: FontWeight.bold)),
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

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Projetos"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Vereadores"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Partidos"),
        ],
      ),
    );
  }
}