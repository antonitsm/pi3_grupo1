import 'package:flutter/material.dart';

import '../paginas/projetos.dart';
import '../paginas/vereadores.dart';
import '../paginas/partido.dart';

class Rodape extends StatelessWidget {
  final int paginaAtual;

  const Rodape({
    super.key,
    required this.paginaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: paginaAtual,
      selectedItemColor: Colors.orange,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProjetosPage(),
            ),
          );
        }

        else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VereadoresPage(),
            ),
          );
        }

        else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PartidosPage(),
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
          icon: Icon(Icons.account_balance),
          label: "Vereadores",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: "Partidos",
        ),
      ],
    );
  }
}