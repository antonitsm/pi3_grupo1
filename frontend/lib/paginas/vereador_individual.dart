import 'package:flutter/material.dart';
import '../widgets/rodape.dart';
import '../mock/mock_data.dart';

class VereadorIndividualPage extends StatelessWidget {
  final Map<String, dynamic> vereador;

  const VereadorIndividualPage({super.key, required this.vereador});

  @override
  Widget build(BuildContext context) {
    final projetosDoVereador = projetosMock
        .where(
          (p) => (p["autoria"] as List).contains(vereador["nome"] as String),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          vereador["nome"] as String,
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(radius: 50, backgroundColor: Colors.black),

            const SizedBox(height: 10),

            Text(
              vereador["nome"] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(vereador["partido"] as String),

            const SizedBox(height: 10),

            // TODO: substituir por dado real do back-end (data início mandato)
            const Text("Início do mandato: 2024"),

            const SizedBox(height: 15),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("${vereador["projetos_aprovados"]} projetos aprovados"),
                  Text(
                    "${(vereador["projetos"] as List).length} projeto(s) vinculado(s)",
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
              (projeto) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projeto["titulo"] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Resumo IA: ${projeto["ideia_central"] as String}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Data: ${projeto["data_publicacao"] as String}"),
                        const Row(
                          children: [
                            Icon(Icons.thumb_up, color: Colors.green),
                            SizedBox(width: 10),
                            Icon(Icons.thumb_down, color: Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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


