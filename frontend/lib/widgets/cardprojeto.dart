import 'package:flutter/material.dart';
import 'projeto_detalhe.dart';
import '../services/api_service.dart';

class CardProjeto extends StatefulWidget {
  final Map<String, dynamic> projeto;

  const CardProjeto({super.key, required this.projeto});

  @override
  State<CardProjeto> createState() => _CardProjetoState();
}

class _CardProjetoState extends State<CardProjeto> {
  final ApiService api = ApiService();

  bool liked = false;
  bool disliked = false;

  @override
  Widget build(BuildContext context) {
    final tags = (widget.projeto["tags"] as List?) ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjetoDetalhePage(projeto: widget.projeto),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projeto["titulo"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              widget.projeto["ideia_central"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 6,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag.toString()),
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
                  widget.projeto["data_publicacao"],
                  style: const TextStyle(fontSize: 12),
                ),

                Row(
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
                          print("Erro ao curtir projeto: $e");
                        }
                      },
                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_up,
                            liked ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.projeto["likes"] ?? 0}",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

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
                          print("Erro ao descurtir projeto: $e");
                        }
                      },
                      child: Row(
                        children: [
                          _reaction(
                            Icons.thumb_down,
                            disliked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.projeto["dislikes"] ?? 0}",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
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
