import 'package:flutter/material.dart';

import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';

import '../services/api_service.dart';

import 'vereador_individual.dart';
 
class VereadoresPage extends StatefulWidget {
  const VereadoresPage({super.key});
 
  @override
  State<VereadoresPage> createState() => _VereadoresPageState();
}
 
class _VereadoresPageState extends State<VereadoresPage> {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> todosVereadores = [];
  List<Map<String, dynamic>> vereadoresFiltrados = [];

  String busca = '';
 
  @override
  void initState() {
    super.initState();
    carregarVereadores();
  }

  Future<void> carregarVereadores() async {
    final vereadores = await api.getVereadores();

    setState(() {
      todosVereadores = List<Map<String, dynamic>>.from(vereadores);
      vereadoresFiltrados = List.from(todosVereadores);
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
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
 
      appBar: const BarraSuperior(),
 
      body: Column(
        children: [
          const SizedBox(height: 10),
 
          // TÍTULO
          const Text(
            "Vereadores",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
 
          const SizedBox(height: 20),
 
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
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("Mais projetos primeiro"),
                              onTap: () {
                                setState(() {
                                  vereadoresFiltrados.sort(
                                    (a, b) =>
                                        (b['projetos'] as List).length.compareTo(
                                              (a['projetos'] as List).length,
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
                                    (a, b) =>
                                        (a['projetos'] as List).length.compareTo(
                                              (b['projetos'] as List).length,
                                            ),
                                  );
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
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
            child: ListView.builder(
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (vereador["foto"] as String).isNotEmpty
                              ? Image.network(
                                  vereador["foto"] as String,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC33505),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vereador["nome"] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(vereador["partido"] as String),
                              const SizedBox(height: 8),
                              Text(
                                "${(vereador["projetos"] as List).length} projetos",
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