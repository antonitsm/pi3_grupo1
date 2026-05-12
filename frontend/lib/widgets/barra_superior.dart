import 'package:flutter/material.dart';

class BarraSuperior extends StatelessWidget
    implements PreferredSizeWidget {

  const BarraSuperior({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      centerTitle: true,

      title: Image.asset(
        'assets/logo.png',
        height: 40,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}