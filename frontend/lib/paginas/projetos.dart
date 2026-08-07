import 'package:flutter/material.dart';

import '../widgets/projeto_detalhe.dart';
import '../widgets/rodape.dart';
import '../widgets/barra_superior.dart';
import './tema/app_text_styles.dart';

import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProjetosPage extends StatefulWidget {
  const ProjetosPage({super.key});

  @override
  State<ProjetosPage> createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
  final ApiService api = ApiService();

  late List<bool> liked;
  late List<bool> disliked;

  List<Map<String, dynamic>> todosProjetos = [];
  List<Map<String, dynamic>> projetosFiltrados = [];

  String busca = "";

  String tagSelecionada = 'Todos';

  bool maisAntigoPrimeiro = false;
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen(abrirProjetoDaNotificacao);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        abrirProjetoDaNotificacao(message);
      }
    });

    carregarProjetos();
  }

  void abrirProjetoDaNotificacao(RemoteMessage message) async {
    final projectId = message.data["projectId"];

    if (projectId == null) return;

    try {
      final projeto = await api.getProjetoPorId(projectId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjetoDetalhePage(projeto: projeto)),
      );
    } catch (e) {
      print("Erro ao abrir projeto da notificação: $e");
    }
  }

  Future<void> carregarProjetos() async {
    setState(() {
      carregando = true;
    });

    final projetos = await api.getProjetos();

    final listaProjetos = List<Map<String, dynamic>>.from(projetos);

    listaProjetos.sort((a, b) {
      final dataA =
          DateTime.tryParse(
            a["data_publicacao"].toString().replaceAll(" ", "T"),
          ) ??
          DateTime(1900);

      final dataB =
          DateTime.tryParse(
            b["data_publicacao"].toString().replaceAll(" ", "T"),
          ) ??
          DateTime(1900);

      return dataB.compareTo(dataA); // mais novo primeiro
    });

    setState(() {
      todosProjetos = listaProjetos;
      projetosFiltrados = List.from(todosProjetos);

      liked = List.generate(todosProjetos.length, (_) => false);
      disliked = List.generate(todosProjetos.length, (_) => false);

      carregando = false;
    });
  }

  void aplicarFiltro() {
    setState(() {
      projetosFiltrados = todosProjetos.where((projeto) {
        if (tagSelecionada == 'Todos') {
          return true;
        }

        return (projeto["tags"] as List).contains(tagSelecionada);
      }).toList();
    });
  }

  void filtrarProjetos(String texto) {
    setState(() {
      busca = texto.toLowerCase();

      projetosFiltrados = todosProjetos.where((projeto) {
        final titulo = projeto["titulo"].toString().toLowerCase();

        final descricao = projeto["ideia_central"].toString().toLowerCase();

        final tags = (projeto["tags"] as List).join(" ").toLowerCase();

        return titulo.contains(busca) ||
            descricao.contains(busca) ||
            tags.contains(busca);
      }).toList();
    });
  }

  String formatarData(dynamic data) {
    if (data == null || data.toString().isEmpty) {
      return "";
    }

    try {
      final dataConvertida = DateTime.parse(
        data.toString().replaceAll(" ", "T"),
      );

      return DateFormat("dd/MM/yyyy").format(dataConvertida);
    } catch (e) {
      return "";
    }
  }

  bool projetoEhNovo(dynamic data) {
    if (data == null || data.toString().isEmpty) {
      return false;
    }

    try {
      final dataProjeto = DateTime.parse(data.toString().replaceAll(" ", "T"));

      final diferenca = DateTime.now().difference(dataProjeto);

      return diferenca.inDays <= 2;
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
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Column(
              children: [
                const SizedBox(height: 10),

                const Text("Projetos", style: AppTextStyles.pageTitle),

                const SizedBox(height: 4),

                const Text(
                  "Leis, decretos e propostas • Itá, Santa Catarina",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // BUSCA
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
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("Mais curtidos"),
                                onTap: () {
                                  setState(() {
                                    projetosFiltrados.sort(
                                      (a, b) => (b["likes"] ?? 0).compareTo(
                                        a["likes"] ?? 0,
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
                                    projetosFiltrados.sort((a, b) {
                                      final dataA =
                                          DateTime.tryParse(
                                            a["data_publicacao"].toString(),
                                          ) ??
                                          DateTime(1900);

                                      final dataB =
                                          DateTime.tryParse(
                                            b["data_publicacao"].toString(),
                                          ) ??
                                          DateTime(1900);

                                      return dataB.compareTo(dataA);
                                    });
                                  });

                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                title: const Text("Mais antigos"),
                                onTap: () {
                                  setState(() {
                                    projetosFiltrados.sort((a, b) {
                                      final dataA =
                                          DateTime.tryParse(
                                            a["data_publicacao"].toString(),
                                          ) ??
                                          DateTime(1900);

                                      final dataB =
                                          DateTime.tryParse(
                                            b["data_publicacao"].toString(),
                                          ) ??
                                          DateTime(1900);

                                      return dataA.compareTo(dataB);
                                    });
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
                        onChanged: filtrarProjetos,
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

            const SizedBox(height: 15),

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
                            "Carregando projetos...",
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: List.generate(
                        projetosFiltrados.length,
                        (index) => _card(
                          context,
                          index,
                          projeto: projetosFiltrados[index],
                        ),
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
                    style: AppTextStyles.cardTitle,
                  ),
                ),

                if (projetoEhNovo(projeto["data_publicacao"]))
                  const Text(
                    "NEW",
                    style: TextStyle(
                      color: Color(0xFFCC3A00),
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
              style: AppTextStyles.body,
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 6,
              children: (projeto["tags"] as List)
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: AppTextStyles.body),
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
                  formatarData(projeto["data_publicacao"]),
                  style: AppTextStyles.body,
                ),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          final resposta = await api.reagirProjeto(
                            projeto["id"].toString(),
                            "like",
                          );

                          setState(() {
                            liked[index] = !liked[index];

                            if (liked[index]) {
                              disliked[index] = false;
                            }

                            if (resposta["likes"] != null) {
                              projeto["likes"] = resposta["likes"];
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
                            liked[index] ? Colors.green : Colors.grey,
                          ),

                          const SizedBox(width: 4),

                          Text("${projeto["likes"] ?? 0}"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () async {
                        try {
                          final resposta = await api.reagirProjeto(
                            projeto["id"].toString(),
                            "dislike",
                          );

                          setState(() {
                            disliked[index] = !disliked[index];

                            if (disliked[index]) {
                              liked[index] = false;
                            }

                            if (resposta["dislikes"] != null) {
                              projeto["dislikes"] = resposta["dislikes"];
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
                            disliked[index] ? Colors.red : Colors.grey,
                          ),

                          const SizedBox(width: 4),

                          Text("${projeto["dislikes"] ?? 0}"),
                        ],
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
