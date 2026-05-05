import 'package:flutter/material.dart';

class ProjetoDetalhePage extends StatelessWidget {
  const ProjetoDetalhePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back),

              const SizedBox(height: 10),

              const Text(
                "Projeto - nome do projeto",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 5),
              const Text("Publicação: 26/04/2026"),

              const SizedBox(height: 20),

              // RESUMO
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Resumo IA ✨",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      "Objetivo: Lorem ipsum dolor sit amet...",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Acesse na íntegra aqui!"),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Vereadores responsáveis:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _vereador(),
                  _vereador(),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _reaction(Icons.thumb_up, Colors.green),
                  const SizedBox(width: 10),
                  _reaction(Icons.thumb_down, Colors.red),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _vereador() {
    return Column(
      children: const [
        CircleAvatar(radius: 28, backgroundColor: Colors.black),
        SizedBox(height: 6),
        Text("Nome do vereador", style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _reaction(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.description), label: "Projetos"),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Vereadores"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Partidos"),
      ],
    );
  }
}