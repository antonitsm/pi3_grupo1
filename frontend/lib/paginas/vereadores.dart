import 'package:flutter/material.dart';

import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import 'vereador_individual.dart';
import './tema/app_text_styles.dart';

import '../services/api_service.dart';

class VereadoresPage extends StatefulWidget {
  const VereadoresPage({super.key});

  @override
  State<VereadoresPage> createState() => _VereadoresPageState();
}

class _VereadoresPageState extends State<VereadoresPage> {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> todosVereadores = [];
  List<Map<String, dynamic>> vereadoresFiltrados = [];
  List<Map<String, dynamic>> todosProjetos = [];
  bool carregando = true;

  String busca = '';

  @override
  void initState() {
    super.initState();
    carregarVereadores();
  }

  Future<void> carregarVereadores() async {
    setState(() {
      carregando = true;
    });

    final vereadores = await api.getVereadores();
    final projetos = await api.getProjetos();

    setState(() {
      todosVereadores = List<Map<String, dynamic>>.from(vereadores);
      todosProjetos = List<Map<String, dynamic>>.from(projetos);
      vereadoresFiltrados = List.from(todosVereadores);

      carregando = false;
    });
  }

  void filtrarVereadores(String texto) {
    setState(() {
      busca = texto.toLowerCase();
      vereadoresFiltrados = todosVereadores.where((v) {
        final nome = (v['nome'] as String).toLowerCase();
        final partido = (v['partido'] as String).toLowerCase();
        return nome.contains(busca) || partido.contains(busca);
      }).toList();
    });
  }

  int quantidadeProjetos(String nomeVereador) {
    return todosProjetos.where((projeto) {
      final autores = (projeto["autoria"] as List?) ?? [];
      return autores.contains(nomeVereador);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: const BarraSuperior(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // TÍTULO
          const Text("Vereadores", style: AppTextStyles.pageTitle),

          const SizedBox(height: 4),

          const Text(
                  "Vereadores do atual mandato em Itá-SC",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w400,
                  ),
                ),

          const SizedBox(height: 15),

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
                                title: const Text("Mais projetos primeiro"),
                                onTap: () {
                                  setState(() {
                                    vereadoresFiltrados.sort(
                                      (a, b) => quantidadeProjetos(b["nome"])
                                          .compareTo(
                                            quantidadeProjetos(a["nome"]),
                                          ),
                                    );
                                  });

                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                title: const Text("Menos projetos primeiro"),
                                onTap: () {
                                  setState(() {
                                    vereadoresFiltrados.sort(
                                      (a, b) => quantidadeProjetos(a["nome"])
                                          .compareTo(
                                            quantidadeProjetos(b["nome"]),
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
                      onChanged: filtrarVereadores,
                      decoration: const InputDecoration(
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
                          "Carregando vereadores...",
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: vereadoresFiltrados.length,
                    itemBuilder: (context, index) {
                      final vereador = vereadoresFiltrados[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VereadorIndividualPage(vereador: vereador),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEAEA),
                            border: Border.all(
                              color: const Color(0xFFC33505),
                              width: 2,
                            ),
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
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.black,
                                backgroundImage:
                                    vereador["fotoUrl"] != null &&
                                        (vereador["fotoUrl"] as String)
                                            .isNotEmpty
                                    ? NetworkImage(vereador["fotoUrl"])
                                    : null,
                                child:
                                    vereador["fotoUrl"] == null ||
                                        (vereador["fotoUrl"] as String).isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vereador["nome"] as String,
                                      style: AppTextStyles.cardTitle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(vereador["partido"] as String),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${quantidadeProjetos(vereador["nome"])} projetos",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: const Rodape(paginaAtual: 1),
    );
  }
}
