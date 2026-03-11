import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AuthService {
  // Get common headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Register User
  Future<String?> register(
    String name,
    String rollNumber,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(AppConfig.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "rollNumber": rollNumber,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // Success
    } else {
      return data["message"]; // Return error message
    }
  }

  // Login User
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString("email", data["user"]["email"]);
      await prefs.setInt("userId", data["user"]["id"]); // Save ID for updates
      return null; // Success
    } else {
      return data["message"]; // Return error message
    }
  }

  // Fetch User Details
  Future<Map<String, String>?> fetchUserDetails(String email) async {
    final response = await http.get(
      Uri.parse("${AppConfig.userDetails}?email=$email"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "name": data["name"] ?? "",
        "rollNumber": data["rollNumber"] ?? "",
        "email": data["email"] ?? "",
      };
    } else {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
