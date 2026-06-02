import 'package:flutter/material.dart';
import 'projeto_detalhe.dart';

class CardProjeto extends StatelessWidget {
  final Map<String, dynamic> projeto;

  const CardProjeto({
    super.key,
    required this.projeto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjetoDetalhePage(
              projeto: projeto,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projeto["titulo"],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
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
              children: (projeto["tags"] as List)
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: const Color(0xFFF67F57),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            Text(
              projeto["data_publicacao"],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}