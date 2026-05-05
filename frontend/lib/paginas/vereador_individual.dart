import 'package:flutter/material.dart';
import 'vereadores.dart'; // importa o model

class VereadorIndividualPage extends StatelessWidget {
  final Vereador vereador;

  const VereadorIndividualPage({required this.vereador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          vereador.nome,
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            CircleAvatar(radius: 50, backgroundColor: Colors.black),

            SizedBox(height: 10),

            Text(
              vereador.nome,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(vereador.partido),

            SizedBox(height: 10),

            Text("Início do mandato: 2024"),

            SizedBox(height: 15),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("20 projetos aprovados"),
                  Text(
                    "3 projetos no último ano",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text("PROJETOS:", style: TextStyle(fontWeight: FontWeight.bold)),

            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nome projeto de lei postado"),
                  SizedBox(height: 5),
                  Text("Mini descrição IA: Lorem ipsum dolor sit amet..."),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Data: xx/xx/20xx"),
                      Row(
                        children: [
                          Icon(Icons.thumb_up, color: Colors.green),
                          SizedBox(width: 10),
                          Icon(Icons.thumb_down, color: Colors.red),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
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