import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OrinocoApi {
  final String baseUrl;
  OrinocoApi({this.baseUrl = 'http://localhost:5000'});

  Future<Map<String, dynamic>> predictCsv(File csvFile) async {
    final url = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', csvFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get prediction: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> trendCsv(File csvFile) async {
    final url = Uri.parse('$baseUrl/trend');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', csvFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get trend: ${response.body}');
    }
  }
}
