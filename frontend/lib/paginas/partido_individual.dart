import 'package:flutter/material.dart';

import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import '../widgets/cardprojeto.dart';

import '../services/api_service.dart';

class PartidoIndividualPage extends StatefulWidget {
  final Map<String, dynamic> partido;

  const PartidoIndividualPage({super.key, required this.partido});

  @override
  State<PartidoIndividualPage> createState() => _PartidoIndividualPageState();
}

class _PartidoIndividualPageState extends State<PartidoIndividualPage> {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> vereadoresDoPartido = [];
  List<Map<String, dynamic>> projetosDoPartido = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final vereadores = await api.getVereadores();
    final projetos = await api.getProjetos();

    final sigla = widget.partido["sigla"] as String;

    final vereadoresFiltrados = List<Map<String, dynamic>>.from(
      vereadores.where((v) => v["partido"] == sigla),
    );

    final nomesVereadores = vereadoresFiltrados
        .map((v) => v["nome"] as String)
        .toSet();

    final projetosFiltrados = List<Map<String, dynamic>>.from(
      projetos.where((p) {
        final autores = (p["autoria"] as List?) ?? [];

        return autores.any(
          (autor) => nomesVereadores.contains(autor),
        );
      }),
    );

    setState(() {
      vereadoresDoPartido = vereadoresFiltrados;
      projetosDoPartido = projetosFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sigla = widget.partido["sigla"] as String;

    final nome = widget.partido["nome"] as String;

    final anoCriacao =
        widget.partido["ano_criacao"] ?? "Não informado";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sigla,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC33505),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF67F57),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.group, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(sigla),
                  Text("Desde $anoCriacao"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${vereadoresDoPartido.length} vereador(es) na câmara",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC3A00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.4,
                            minChildSize: 0.3,
                            maxChildSize: 0.8,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),

                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    Text(
                                      "Vereadores do $sigla",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: vereadoresDoPartido.length,
                                        itemBuilder: (context, index) {
                                          final vereador =
                                              vereadoresDoPartido[index];

                                          return ListTile(
                                            leading: const CircleAvatar(
                                              child: Icon(Icons.person),
                                            ),
                                            title: Text(
                                              vereador["nome"] as String,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Conferir nomes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confira os projetos de lei do $sigla:",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: projetosDoPartido.length,
                itemBuilder: (context, index) {
                  final projeto = projetosDoPartido[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CardProjeto(projeto: projeto),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: const Rodape(paginaAtual: 2),
    );
  }
}
