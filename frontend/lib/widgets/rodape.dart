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

      backgroundColor: const Color(0xFFC33505),

      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,

      selectedFontSize: 14,
      unselectedFontSize: 13,

      type: BottomNavigationBarType.fixed,

      onTap: (index){
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
          icon: SizedBox(
            width: 45,
            height: 45,
            child: ImageIcon(
              AssetImage('assets/imagens/iconProjetos.png'),
            ),
          ),
          label: "Projetos",
        ),

        BottomNavigationBarItem(
          icon: SizedBox(
            width: 55,
            height: 55,
            child: ImageIcon(
              AssetImage('assets/imagens/iconVereadores.png'),
            ),
          ),
          label: "Vereadores",
        ),

        BottomNavigationBarItem(
          icon: SizedBox(
            width: 45,
            height: 45,
            child: ImageIcon(
              AssetImage('assets/imagens/iconPartidos.png'),
            ),
          ),
          label: "Partidos",
        ),
      ],
    );
  }
}