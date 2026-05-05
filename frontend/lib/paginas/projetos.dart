import 'tema/app_colors.dart';
import 'package:flutter/material.dart';
import 'projeto_detalhe.dart';

class ProjetosPage extends StatelessWidget {
  const ProjetosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Column(
              children: [
                Container(
                  height: 3,
                  width: double.infinity,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Projetos",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // BUSCA + FILTRO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.tune, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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

            const SizedBox(height: 15),

            // LISTA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _card(context, isNew: true),
                  _card(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {bool isNew = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjetoDetalhePage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // título + NEW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Nome projeto de lei postado",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (isNew)
                  const Text(
                    "NEW",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              "Mini descrição IA: Lorem ipsum dolor sit amet...",
              style: TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Data: xx/xx/20xx",
                    style: TextStyle(fontSize: 12)),

                Row(
                  children: [
                    _reaction(Icons.thumb_up, Colors.green),
                    const SizedBox(width: 6),
                    _reaction(Icons.thumb_down, Colors.red),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _reaction(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
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