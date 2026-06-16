import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:5001/transparencia-municipal-4e915/us-central1";

  Future<List<dynamic>> getProjetos() async {
    final response =
        await http.get(Uri.parse("$baseUrl/projetos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar projetos");
  }

  Future<List<dynamic>> getVereadores() async {
    final response =
        await http.get(Uri.parse("$baseUrl/vereadores"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar vereadores");
  }

  Future<List<dynamic>> getPartidos() async {
    final response =
        await http.get(Uri.parse("$baseUrl/partidos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar partidos");
  }
}