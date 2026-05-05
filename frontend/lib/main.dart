import 'package:flutter/material.dart';
import 'paginas/vereadores.dart';
import 'paginas/vereador_individual.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VereadoresPage(),
    );
  }
}