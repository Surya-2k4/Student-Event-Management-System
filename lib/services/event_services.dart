import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class EventService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<bool> registerEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse(AppConfig.registerEvent),
      headers: await _getHeaders(),
      body: jsonEncode(eventData),
    );

    return response.statusCode == 201;
  }

  Future<List<dynamic>> fetchEvents({String? email, Map<String, String>? filters}) async {
    String url = AppConfig.viewEvents;
    if (email != null) {
      url += "?email=$email";
    }
    
    // Append filters
    if (filters != null) {
      filters.forEach((key, value) {
        url += url.contains('?') ? "&$key=$value" : "?$key=$value";
      });
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}
