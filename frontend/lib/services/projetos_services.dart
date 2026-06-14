import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://SEU-ENDERECO';

  Future<List<dynamic>> getProjetos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projetos'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao carregar projetos');
  }
}