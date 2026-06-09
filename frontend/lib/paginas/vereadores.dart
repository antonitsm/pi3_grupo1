
import 'package:flutter/material.dart';
import '../widgets/barra_superior.dart';
import '../widgets/rodape.dart';
import '../mock/mock_data.dart';
import 'vereador_individual.dart';
 
class VereadoresPage extends StatefulWidget {
  const VereadoresPage({super.key});
 
  @override
  State<VereadoresPage> createState() => _VereadoresPageState();
}
 
class _VereadoresPageState extends State<VereadoresPage> {
  final TextEditingController _searchController = TextEditingController();
 
  String _busca = '';
 
  // 'none' | 'asc' | 'desc'
  String _ordenacao = 'none';
 
  List<Map<String, dynamic>> get _vereadoresFiltrados {
    List<Map<String, dynamic>> lista = vereadoresMock
        .cast<Map<String, dynamic>>()
        .where((v) {
          final termo = _busca.toLowerCase();
          return (v['nome'] as String).toLowerCase().contains(termo) ||
              (v['partido'] as String).toLowerCase().contains(termo);
        })
        .toList();
 
    if (_ordenacao == 'asc') {
      lista.sort((a, b) =>
          (a['projetos'] as List).length.compareTo((b['projetos'] as List).length));
    } else if (_ordenacao == 'desc') {
      lista.sort((a, b) =>
          (b['projetos'] as List).length.compareTo((a['projetos'] as List).length));
    }
 
    return lista;
  }
 
  void _alternarOrdenacao() {
    setState(() {
      if (_ordenacao == 'none' || _ordenacao == 'desc') {
        _ordenacao = 'asc';
      } else {
        _ordenacao = 'desc';
      }
    });
  }
 
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final lista = _vereadoresFiltrados;
 
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
                Tooltip(
                  message: _ordenacao == 'asc'
                      ? 'Ordenando: menos projetos primeiro'
                      : _ordenacao == 'desc'
                          ? 'Ordenando: mais projetos primeiro'
                          : 'Ordenar por quantidade de projetos',
                  child: GestureDetector(
                    onTap: _alternarOrdenacao,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          Icons.tune,
                          color: _ordenacao != 'none'
                              ? const Color(0xFFCC3A00)
                              : const Color(0xFFCC3A00),
                          size: 28,
                        ),
                        if (_ordenacao != 'none')
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              _ordenacao == 'asc'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: const Color(0xFFCC3A00),
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _busca = value;
                        });
                      },
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
 
          // Indicador de ordenação ativa
          if (_ordenacao != 'none')
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                children: [
                  const SizedBox(width: 38),
                  Icon(
                    _ordenacao == 'asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 14,
                    color: const Color(0xFFCC3A00),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _ordenacao == 'asc'
                        ? 'Menos projetos primeiro'
                        : 'Mais projetos primeiro',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFCC3A00),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _ordenacao = 'none'),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCC3A00),
                        decoration: TextDecoration.underline,
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
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final vereador = lista[index];
 
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