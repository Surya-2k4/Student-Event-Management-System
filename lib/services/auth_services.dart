import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:5000"; // Change to your backend URL

  // Register User
  Future<String?> register(
    String name,
    String rollNumber,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "rollNumber": rollNumber,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return null; // Success
    } else {
      return data["message"]; // Return error message
    }
  }

  // Login User
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString("email", data["user"]["email"]);
      return null; // Success
    } else {
      return data["message"]; // Return error message
    }
  }

  // Fetch User Details
  Future<Map<String, String>?> fetchUserDetails(String email) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user?email=$email"),
      headers: {"Content-Type": "application/json"},
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
