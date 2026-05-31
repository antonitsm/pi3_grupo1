import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/projeto.dart';

class ProjetoService {  //recebe e transforma dados do backend

  static const String baseUrl = '';

  Future<List<Projeto>> getProjetos() async {

    final response =
        await http.get(Uri.parse('$baseUrl/projetos')); //faz requisição do back

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data //converte json em widget
          .map((json) => Projeto.fromJson(json))
          .toList();
    }

    throw Exception('Erro ao carregar projetos');
  }
}