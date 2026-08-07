import 'package:flutter/material.dart';

import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import '../widgets/cardprojeto.dart';
import 'vereador_individual.dart';
import './tema/app_text_styles.dart';

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
    final sigla = widget.partido["sigla"];

    final vereadores = await api.getVereadores();

    final projetos = await api.getProjetos();

    final vereadoresFiltrados = vereadores.where((v) {
      return v["partido"] == sigla;
    }).toList();

    final nomesVereadores = vereadoresFiltrados
        .map((v) => v["nome"] as String)
        .toSet();

    final projetosFiltrados = projetos.where((p) {
      final autores = (p["autoria"] as List?) ?? [];

      return autores.any((autor) => nomesVereadores.contains(autor));
    }).toList();

    setState(() {
      vereadoresDoPartido = List<Map<String, dynamic>>.from(
        vereadoresFiltrados,
      );

      projetosDoPartido = List<Map<String, dynamic>>.from(projetosFiltrados);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sigla = widget.partido["sigla"] as String;
    final nome = widget.partido["nome"] as String;
    final anoCriacao = widget.partido["ano_criacao"] ?? "Não informado";
    final numero = widget.partido["numero"]?.toString();
    final logoUrl = widget.partido["logoUrl"]?.toString();
    final corHex = widget.partido["cor"]?.toString() ?? "#000000";

    final cor = Color(int.parse(corHex.replaceFirst("#", "0xFF")));

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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC33505),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                border: Border.all(color: cor, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                        ? NetworkImage(logoUrl)
                        : null,
                    child: logoUrl == null || logoUrl.isEmpty
                        ? const Icon(
                            Icons.groups,
                            size: 50,
                            color: Color(0xFF151515),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nome,
                    style: AppTextStyles.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                  Text(sigla, style: AppTextStyles.body),
                  Text("Desde $anoCriacao", style: AppTextStyles.body),
                  Text("Número: $numero", style: AppTextStyles.body),
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
                      style: AppTextStyles.body,
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
                                      style: AppTextStyles.cardTitle,
                                    ),

                                    const SizedBox(height: 12),

                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: vereadoresDoPartido.length,
                                        itemBuilder: (context, index) {
                                          final vereador =
                                              vereadoresDoPartido[index];

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                    vereador["fotoUrl"] !=
                                                            null &&
                                                        vereador["fotoUrl"]
                                                            .toString()
                                                            .isNotEmpty
                                                    ? NetworkImage(
                                                        vereador["fotoUrl"],
                                                      )
                                                    : null,
                                                child:
                                                    vereador["fotoUrl"] ==
                                                            null ||
                                                        vereador["fotoUrl"]
                                                            .toString()
                                                            .isEmpty
                                                    ? const Icon(Icons.person)
                                                    : null,
                                              ),

                                              title: Text(
                                                vereador["nome"] as String,
                                              ),

                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        VereadorIndividualPage(
                                                          vereador: vereador,
                                                        ),
                                                  ),
                                                );
                                              },
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
                  style: AppTextStyles.cardTitle,
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
