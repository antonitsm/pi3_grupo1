import 'package:flutter/material.dart';

import 'tema/app_colors.dart';
import 'projeto_detalhe.dart';
import 'vereadores.dart';
import 'partido.dart';

class ProjetosPage extends StatefulWidget {
  const ProjetosPage({super.key});

  @override
  State<ProjetosPage> createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
List<bool> liked = [false, false];
List<bool> disliked = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _bottomNav(context),

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

            // BUSCA
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
                  _card(context, 0, isNew: true),
                  _card(context, 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, int index, {bool isNew = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProjetoDetalhePage(),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Expanded(
                  child: Text(
                    "Nome projeto de lei postado",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (isNew)
                  const Text(
                    "NEW",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                const Text(
                  "Data: xx/xx/20xx",
                  style: TextStyle(fontSize: 12),
                ),

               Row(
  children: [
    GestureDetector(
      onTap: () {
       setState(() {
  liked[index] = !liked[index];

  if (liked[index]) {
    disliked[index] = false;
  }
});
      },

      child: _reaction(
        Icons.thumb_up,
        liked[index] ? Colors.green : Colors.grey,
      ),
    ),

    const SizedBox(width: 6),

    GestureDetector(
      onTap: () {
      setState(() {
  disliked[index] = !disliked[index];

  if (disliked[index]) {
    liked[index] = false;
  }
});
      },

      child: _reaction(
        Icons.thumb_down,
        disliked[index] ? Colors.red : Colors.grey,
      ),
    ),
  ],
),
              ],
            ),
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

      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex: 0,
    selectedItemColor: AppColors.primary,

    onTap: (index) {
      if (index == 0) return;

      final pages = [
        ProjetosPage(),
        VereadoresPage(),
        PartidosPage(),
      ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => pages[index],
        ),
      );
    },

    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.description),
        label: "Projetos",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.groups),
        label: "Vereadores",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: "Partidos",
      ),
    ],
  );
}
  }