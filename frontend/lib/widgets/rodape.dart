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
          icon: ImageIcon (AssetImage('assets/imagens/iconProjetos.png')),
          label: "Projetos",
        ),

        BottomNavigationBarItem(
          icon: ImageIcon (AssetImage('assets/imagens/iconVereadores.png')),
          label: "Vereadores",
        ),

        BottomNavigationBarItem(
          icon: ImageIcon (AssetImage('assets/imagens/iconPartidos.png')),
          label: "Partidos",
        ),
      ],
    );
  }
}