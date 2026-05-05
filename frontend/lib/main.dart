import 'package:flutter/material.dart';
import 'paginas/vereadores.dart';
<<<<<<< HEAD
import 'paginas/vereador_individual.dart';

=======
import 'paginas/partido.dart';
import 'paginas/partido_individual.dart';
>>>>>>> 9df9e303c99482d9a8224e415431c69c93477abe
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