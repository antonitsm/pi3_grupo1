import "../mock/mock_data.dart";

class ApiService {
  Future<List<dynamic>> getProjetos() async {
    return projetosMock;
  }

  Future<List<dynamic>> getVereadores() async {
    return vereadoresMock;
  }

  Future<List<dynamic>> getPartidos() async {
    return partidosMock;
  }
}