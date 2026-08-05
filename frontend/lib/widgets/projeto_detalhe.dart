import 'package:flutter/material.dart';

import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';
import '../paginas/tema/app_text_styles.dart';

import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjetoDetalhePage extends StatefulWidget {
  final Map<String, dynamic> projeto;

  const ProjetoDetalhePage({super.key, required this.projeto});

  @override
  State<ProjetoDetalhePage> createState() => _ProjetoDetalhePageState();
}

class _ProjetoDetalhePageState extends State<ProjetoDetalhePage> {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> vereadoresProjeto = [];

  bool liked = false;
  bool disliked = false;

  @override
  void initState() {
    super.initState();
    carregarVereadores();
  }

  Future<void> carregarVereadores() async {
    final vereadores = await api.getVereadores();

    final vereadoresFiltrados = List<Map<String, dynamic>>.from(
      vereadores.where(
        (vereador) =>
            (widget.projeto["autoria"] as List).contains(vereador["nome"]),
      ),
    );

    setState(() {
      vereadoresProjeto = vereadoresFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const Rodape(paginaAtual: 0),
      appBar: const BarraSuperior(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),

                Text(widget.projeto["titulo"], style: AppTextStyles.pageTitle),

                const SizedBox(height: 5),
                Text(
                  "Publicação: ${widget.projeto["data_publicacao"]}",
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 20),

                // RESUMO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: const Color(0xFFED5523),
                      width: 2,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Resumo IA ✨", style: AppTextStyles.cardTitle),

                      const SizedBox(height: 12),

                      Text(
                        "🎯 Objetivo\n${widget.projeto["ideia_central"]}",
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "📍 Localidades afetadas\n${widget.projeto["localidades_afetadas"]}",
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "📅 Quando será executado\n${widget.projeto["quando_sera_executado"]}",
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "⚙️ Como será executado\n${widget.projeto["como_sera_executado"]}",
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "👤 Autoria\n${(widget.projeto["autoria"] as List).join(", ")}",
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: const Color(0xFFF67F57),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Relevância: ${widget.projeto["relevancia"]}",
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              widget.projeto["justificativa_relevancia"],
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÃO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC3A00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final url = widget.projeto["textoOriginalUrl"];

                      if (url != null && url.isNotEmpty) {
                        final uri = Uri.parse(url);

                        if (await launchUrl(uri)) {
                          print("Abrindo link");
                        } else {
                          print("Não foi possível abrir");
                        }
                      }
                    },
                    child: Text(
                      "Acesse na íntegra aqui!",
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Vereadores responsáveis:",
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  children: vereadoresProjeto
                      .map((vereador) => _vereador(vereador))
                      .toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          final resposta = await api.reagirProjeto(
                            widget.projeto["id"].toString(),
                            "like",
                          );

                          setState(() {
                            liked = !liked;

                            if (liked) {
                              disliked = false;
                            }

                            if (resposta["likes"] != null) {
                              widget.projeto["likes"] = resposta["likes"];
                            }
                          });
                        } catch (e) {
                          print("Erro no like: $e");
                        }
                      },

                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_up,
                            liked ? Colors.green : null,
                          ),

                          const SizedBox(width: 5),

                          Text("${widget.projeto["likes"] ?? 0}"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () async {
                        try {
                          final resposta = await api.reagirProjeto(
                            widget.projeto["id"].toString(),
                            "dislike",
                          );

                          setState(() {
                            disliked = !disliked;

                            if (disliked) {
                              liked = false;
                            }

                            if (resposta["dislikes"] != null) {
                              widget.projeto["dislikes"] = resposta["dislikes"];
                            }
                          });
                        } catch (e) {
                          print("Erro no dislike: $e");
                        }
                      },

                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_down,
                            disliked ? Colors.red : null,
                          ),

                          const SizedBox(width: 5),

                          Text("${widget.projeto["dislikes"] ?? 0}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vereador(Map<String, dynamic> vereador) {
    return Column(
      children: [
        const CircleAvatar(radius: 30, backgroundColor: Colors.black),

        const SizedBox(height: 6),

        Text(vereador["nome"], style: const TextStyle(fontSize: 12)),

        Text(
          vereador["partido"],
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _reaction(IconData icon, Color? color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE0E0E0), // cinza quando não selecionado
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: color == null ? Colors.grey.shade700 : Colors.white,
      ),
    );
  }
}
