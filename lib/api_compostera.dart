import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiCompostera {
  static const baseUrl = 'https://apicompostera.hackfunrosario.com';

  static Future<void> createIdea(Map<String, dynamic> idea) async {
    final url = Uri.parse('$baseUrl/api/ideas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(idea),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to create idea');
    }
  }

  static Future<List<Map<String, dynamic>>> getIdeas() async {
    final url = Uri.parse('$baseUrl/api/ideas');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load ideas');
    }
  }

  static Future<http.Response> deleteIdeaById(String id) async {
    final url = Uri.parse('$baseUrl/api/ideas?id=$id');
    return await http.delete(url);
  }

  static Future<http.Response> deleteAllIdeas() async {
    final url = Uri.parse('$baseUrl/api/ideas?todas=true');

    final res = await http.delete(url);
    log('deleteAllIdeas: ${res.statusCode} - ${res.body}');
    return res;
  }
}
