import 'package:flutter/material.dart';
import 'projeto_detalhe.dart';

class CardProjeto extends StatefulWidget {
  final Map<String, dynamic> projeto;

  const CardProjeto({
    super.key,
    required this.projeto,
  });

  @override
  State<CardProjeto> createState() => _CardProjetoState();
}

class _CardProjetoState extends State<CardProjeto> {
  bool liked = false;
  bool disliked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjetoDetalhePage(
              projeto: widget.projeto,
            ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
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
              children: (widget.projeto["tags"] as List)
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
                  widget.projeto["data_publicacao"],
                  style: const TextStyle(fontSize: 12),
                ),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          liked = !liked;
                          if (liked) disliked = false;
                        });
                      },
                      child: _reaction(
                        Icons.thumb_up,
                        liked ? Colors.green : Colors.grey,
                      ),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          disliked = !disliked;
                          if (disliked) liked = false;
                        });
                      },
                      child: _reaction(
                        Icons.thumb_down,
                        disliked ? Colors.red : Colors.grey,
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
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}