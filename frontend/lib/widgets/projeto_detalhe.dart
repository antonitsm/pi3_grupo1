import 'package:flutter/material.dart';

import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';
import '../paginas/tema/app_text_styles.dart';
import '../paginas/vereador_individual.dart';

import '../services/api_service.dart';
import 'package:intl/intl.dart';
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
  bool enviandoReacao = false;
  int likes = 0;
  int dislikes = 0;

  @override
  void initState() {
    super.initState();

    likes = widget.projeto["likes"] ?? 0;
    dislikes = widget.projeto["dislikes"] ?? 0;

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

  String formatarData(dynamic data) {
    if (data == null || data.toString().isEmpty) {
      return "";
    }

    try {
      final dataConvertida = DateTime.parse(data.toString());

      return DateFormat("dd/MM/yyyy").format(dataConvertida);
    } catch (e) {
      return data.toString();
    }
  }

  bool projetoEhNovo(dynamic data) {
    if (data == null || data.toString().isEmpty) {
      return false;
    }

    try {
      final dataProjeto = DateTime.parse(data.toString());

      return DateTime.now().difference(dataProjeto).inHours <= 48;
    } catch (e) {
      return false;
    }
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
                  "Publicação: ${formatarData(widget.projeto["data_publicacao"])}",
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
                  spacing: 30,
                  runSpacing: 20,
                  children: vereadoresProjeto
                      .map((vereador) => _vereador(vereador))
                      .toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: enviandoReacao
                          ? null
                          : () async {
                              setState(() {
                                enviandoReacao = true;

                                if (liked) {
                                  liked = false;
                                  likes--;
                                } else {
                                  liked = true;
                                  likes++;

                                  if (disliked) {
                                    disliked = false;
                                    dislikes--;
                                  }
                                }
                              });

                              try {
                                final resposta = await api.reagirProjeto(
                                  widget.projeto["id"].toString(),
                                  "like",
                                );

                                setState(() {
                                  if (resposta["likes"] != null) {
                                    likes = resposta["likes"];
                                  }
                                });
                              } catch (e) {
                                // desfaz caso dê erro
                                setState(() {
                                  if (liked) {
                                    liked = false;
                                    likes--;
                                  } else {
                                    liked = true;
                                    likes++;
                                  }
                                });

                                print("Erro no like: $e");
                              } finally {
                                setState(() {
                                  enviandoReacao = false;
                                });
                              }
                            },

                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_up,
                            liked ? Colors.green : null,
                          ),

                          const SizedBox(width: 5),

                          Text("$likes"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: enviandoReacao
                          ? null
                          : () async {
                              setState(() {
                                enviandoReacao = true;

                                if (disliked) {
                                  disliked = false;
                                  dislikes--;
                                } else {
                                  disliked = true;
                                  dislikes++;

                                  if (liked) {
                                    liked = false;
                                    likes--;
                                  }
                                }
                              });

                              try {
                                final resposta = await api.reagirProjeto(
                                  widget.projeto["id"].toString(),
                                  "dislike",
                                );

                                setState(() {
                                  if (resposta["dislikes"] != null) {
                                    dislikes = resposta["dislikes"];
                                  }
                                });
                              } catch (e) {
                                print("Erro no dislike: $e");

                                // desfaz caso falhe
                                setState(() {
                                  if (disliked) {
                                    disliked = false;
                                    dislikes--;
                                  } else {
                                    disliked = true;
                                    dislikes++;
                                  }
                                });
                              } finally {
                                setState(() {
                                  enviandoReacao = false;
                                });
                              }
                            },

                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_down,
                            disliked ? Colors.red : null,
                          ),

                          const SizedBox(width: 5),

                          Text("$dislikes"),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VereadorIndividualPage(vereador: vereador),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  vereador["fotoUrl"] != null &&
                      vereador["fotoUrl"].toString().isNotEmpty
                  ? NetworkImage(vereador["foto"])
                  : null,
              child:
                  vereador["fotoUrl"] == null ||
                      vereador["fotoUrl"].toString().isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 110,
              child: Text(
                vereador["nome"],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              vereador["partido"],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
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
