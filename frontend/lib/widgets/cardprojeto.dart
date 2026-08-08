import 'package:flutter/material.dart';
import 'projeto_detalhe.dart';
import 'package:intl/intl.dart';

class CardProjeto extends StatelessWidget {
  final Map<String, dynamic> projeto;

  const CardProjeto({super.key, required this.projeto});

  String formatarDataPublicacao(dynamic data) {
    if (data == null || data.toString().isEmpty) {
      return "";
    }

    try {
      final dataConvertida = DateTime.parse(data.toString());

      return DateFormat("dd/MM/yyyy").format(dataConvertida);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = (projeto["tags"] as List?) ?? [];

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projeto["titulo"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              projeto["ideia_central"],
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
                  formatarDataPublicacao(projeto["data_publicacao"]),
                  style: const TextStyle(fontSize: 12),
                ),

                Row(
                  children: [
                    _reaction(
                      Icons.thumb_up,
                      Colors.green,
                      projeto["likes"] ?? 0,
                    ),

                    const SizedBox(width: 12),

                    _reaction(
                      Icons.thumb_down,
                      Colors.red,
                      projeto["dislikes"] ?? 0,
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

  Widget _reaction(IconData icon, Color color, dynamic quantidade) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),

        const SizedBox(width: 4),

        Text(
          "$quantidade",
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
