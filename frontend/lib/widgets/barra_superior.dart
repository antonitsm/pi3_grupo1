import 'package:flutter/material.dart';

class BarraSuperior extends StatelessWidget
    implements PreferredSizeWidget {

  const BarraSuperior({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,

      flexibleSpace: SafeArea(
        child: Image.asset(
          'assets/imagens/imagemBarraSup.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}