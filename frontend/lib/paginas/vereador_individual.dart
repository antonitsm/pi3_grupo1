import '../widgets/cardprojeto.dart';
import 'package:flutter/material.dart';
import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import '../services/api_service.dart';

class VereadorIndividualPage extends StatefulWidget {
  final Map<String, dynamic> vereador;

  const VereadorIndividualPage({super.key, required this.vereador});

  @override
  State<VereadorIndividualPage> createState() => _VereadorIndividualPageState();
}

class _VereadorIndividualPageState extends State<VereadorIndividualPage> {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> projetosDoVereador = [];

  @override
  void initState() {
    super.initState();
    carregarProjetos();
  }

  Future<void> carregarProjetos() async {
    final projetos = await api.getProjetos();

    setState(() {
      projetosDoVereador = List<Map<String, dynamic>>.from(
        projetos.where((p) {
          final autores = (p["autoria"] as List?) ?? [];

          return autores.contains(widget.vereador["nome"]);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Stack(children: [const BarraSuperior()]),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const CircleAvatar(radius: 50, backgroundColor: Colors.black),

            const SizedBox(height: 10),

            Text(
              widget.vereador["nome"] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(widget.vereador["partido"] as String),

            const SizedBox(height: 10),

            // TODO: substituir por dado real do back-end (data início mandato)
            const Text("Início do mandato: 2024"),

            const SizedBox(height: 15),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 233, 233),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    "${projetosDoVereador.length} projeto(s) vinculado(s)",
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "PROJETOS:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            ...projetosDoVereador.map(
              (projeto) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                child: CardProjeto(projeto: projeto),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: const Rodape(paginaAtual: 1),
    );
  }
}
