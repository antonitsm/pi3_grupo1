import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  Future<List<dynamic>> getProjetos() async {
    final response = await http.get(
      Uri.parse(
        "https://projetos-ht6dkigglq-uc.a.run.app",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar projetos");
  }

  Future<Map<String, dynamic>> getProjetoPorId(String id) async {
  final response = await http.get(
    Uri.parse(
      "https://projeto-ht6dkigglq-uc.a.run.app?id=$id",
    ),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception("Erro ao carregar projeto");
}

  Future<List<dynamic>> getVereadores() async {
    final response = await http.get(
      Uri.parse(
        "https://vereadores-ht6dkigglq-uc.a.run.app",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar vereadores");
  }

  Future<List<dynamic>> getPartidos() async {
    final response = await http.get(
      Uri.parse(
        "https://partidos-ht6dkigglq-uc.a.run.app",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar partidos");
  }

  Future<List<dynamic>> getPartidoVereadores(String partidoId) async {
    final response = await http.get(
      Uri.parse(
        "https://partido-vereadores-ht6dkigglq-uc.a.run.app?id=$partidoId",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar vereadores do partido");
  }

  Future<List<dynamic>> getPartidoProjetos(String partidoId) async {
    final response = await http.get(
      Uri.parse(
        "https://partido-projetos-ht6dkigglq-uc.a.run.app?id=$partidoId",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar projetos do partido");
  }
}