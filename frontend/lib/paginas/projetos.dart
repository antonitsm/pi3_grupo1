import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../widgets/projeto_detalhe.dart';
import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';

class ProjetosPage extends StatefulWidget {
  const ProjetosPage({super.key});

  @override
  State<ProjetosPage> createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
  late List<bool> liked;
  late List<bool> disliked;

  @override
  void initState() {
    super.initState();

    liked = List.generate(projetosMock.length, (_) => false);

    disliked = List.generate(projetosMock.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const Rodape(paginaAtual: 0),

      appBar: const BarraSuperior(),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Column(
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Projetos",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // BUSCA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  Icon(Icons.tune, color: const Color(0xFFCC3A00)),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      height: 40,

                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA),
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

                children: List.generate(
                  projetosMock.length,
                  (index) =>
                      _card(context, index, projeto: projetosMock[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    int index, {
    required Map<String, dynamic> projeto,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjetoDetalhePage(projeto: projeto),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
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
                Expanded(
                  child: Text(
                    projeto["titulo"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                if (index > 3)
                  const Text(
                    "NEW",
                    style: TextStyle(
                      color: const Color(0xFFCC3A00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              projeto["ideia_central"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 6,
              children: (projeto["tags"] as List)
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: const Color(0xFFF67F57),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  projeto["data_publicacao"],
                  style: const TextStyle(fontSize: 12),
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

      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

