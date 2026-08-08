import 'package:flutter/material.dart';

import 'partido_individual.dart';
import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';
import './tema/app_text_styles.dart';

import '../services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PartidosPage(),
    );
  }
}

class PartidosPage extends StatefulWidget {
  const PartidosPage({super.key});

  @override
  State<PartidosPage> createState() => _PartidosPageState();
}

class _PartidosPageState extends State<PartidosPage> {
  final ApiService api = ApiService();

  bool carregando = true;
  List<Map<String, dynamic>> todosPartidos = [];
  List<Map<String, dynamic>> todosVereadores = [];
  List<Map<String, dynamic>> todosProjetos = [];
  List<Map<String, dynamic>> partidosFiltrados = [];
  String busca = "";

  @override
  void initState() {
    super.initState();
    carregarPartidos();
  }

  Future<void> carregarPartidos() async {
    setState(() {
      carregando = true;
    });

    final partidos = await api.getPartidos();
    final vereadores = await api.getVereadores();
    final projetos = await api.getProjetos();

    setState(() {
      todosPartidos = List<Map<String, dynamic>>.from(partidos);
      todosVereadores = List<Map<String, dynamic>>.from(vereadores);
      todosProjetos = List<Map<String, dynamic>>.from(projetos);
      partidosFiltrados = List.from(todosPartidos);

      carregando = false;
    });
  }

  void filtrarPartidos(String texto) {
    setState(() {
      busca = texto.toLowerCase();

      partidosFiltrados = todosPartidos.where((partido) {
        final nome = partido["nome"].toString().toLowerCase();

        final sigla = partido["sigla"].toString().toLowerCase();

        return nome.contains(busca) || sigla.contains(busca);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // HEADER
      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // TÍTULO
          const Center(child: Text("Partidos", style: AppTextStyles.pageTitle)),

          const SizedBox(height: 28),

          // FILTRO + BUSCA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFFCC3A00)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      builder: (context) {
                        return SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("A-Z"),
                                onTap: () {
                                  setState(() {
                                    partidosFiltrados.sort(
                                      (a, b) =>
                                          a["sigla"].compareTo(b["sigla"]),
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                title: const Text("Z-A"),
                                onTap: () {
                                  setState(() {
                                    partidosFiltrados.sort(
                                      (a, b) =>
                                          b["sigla"].compareTo(a["sigla"]),
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                title: const Text("Mais antigos"),
                                onTap: () {
                                  setState(() {
                                    partidosFiltrados.sort(
                                      (a, b) => a["ano_criacao"].compareTo(
                                        b["ano_criacao"],
                                      ),
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                title: const Text("Mais novos"),
                                onTap: () {
                                  setState(() {
                                    partidosFiltrados.sort(
                                      (a, b) => b["ano_criacao"].compareTo(
                                        a["ano_criacao"],
                                      ),
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    height: 40,

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: TextField(
                      onChanged: filtrarPartidos,
                      decoration: const InputDecoration(
                        hintText: "Buscar partido",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LISTA
          Expanded(
            child: carregando
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFCC3A00)),
                        SizedBox(height: 16),
                        Text(
                          "Carregando partidos...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: partidosFiltrados.length,
                    itemBuilder: (context, index) {
                      final partido = partidosFiltrados[index];

                      final sigla = partido["sigla"];

                      final vereadoresDoPartido = todosVereadores
                          .where((v) => v["partido"] == sigla)
                          .toList();

                      final nomesVereadores = vereadoresDoPartido
                          .map((v) => v["nome"] as String)
                          .toSet();

                      final projetosDoPartido = todosProjetos.where((p) {
                        final autores = (p["autoria"] as List?) ?? [];

                        return autores.any(
                          (autor) => nomesVereadores.contains(autor),
                        );
                      }).toList();

                      return PartidoCard(
                        partido: partido,
                        quantidadeProjetos: projetosDoPartido.length,
                        quantidadeVereadores: vereadoresDoPartido.length,
                      );
                    },
                  ),
          ),
        ],
      ),

      // FOOTER
      bottomNavigationBar: const Rodape(paginaAtual: 2),
    );
  }
}

// CARD
class PartidoCard extends StatelessWidget {
  final Map<String, dynamic> partido;
  final int quantidadeProjetos;
  final int quantidadeVereadores;

  const PartidoCard({
    super.key,
    required this.partido,
    required this.quantidadeProjetos,
    required this.quantidadeVereadores,
  });

  @override
  Widget build(BuildContext context) {
    final logoUrl = partido["logoUrl"] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PartidoIndividualPage(partido: partido),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFA1B4BE),
                image: logoUrl != null && logoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoUrl == null || logoUrl.isEmpty
                  ? const Icon(Icons.groups, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(partido["sigla"], style: AppTextStyles.cardTitle),

                  const SizedBox(height: 4),

                  Text(partido["nome"], style: AppTextStyles.body),

                  const SizedBox(height: 8),

                  Text(
                    "$quantidadeProjetos projetos • "
                    "$quantidadeVereadores vereadores",
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
