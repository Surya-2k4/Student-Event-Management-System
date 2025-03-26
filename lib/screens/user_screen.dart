import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/services/auth_services.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String name = "";
  String rollNumber = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email") ?? "";
    final userDetails = await AuthService().fetchUserDetails(email);
    if (userDetails != null) {
      setState(() {
        name = userDetails["name"]!;
        rollNumber = userDetails["rollNumber"]!;
        this.email = userDetails["email"]!;
      });
    } else {
      setState(() {
        name = "";
        rollNumber = "";
        this.email = email;
      });
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future<bool> _onWillPop() async {
    return false; // Prevent back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "User Profile",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          automaticallyImplyLeading: false, // Prevent back button
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout, color: Color.fromARGB(255, 254, 253, 253)),
            ),
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoTile(Icons.person_outline, "Name", name),
                      if (!email.endsWith('@kongu.ac.in'))
                        _buildInfoTile(
                          Icons.badge_outlined,
                          "Roll Number",
                          rollNumber,
                        ),
                      _buildInfoTile(Icons.email_outlined, "Gmail", email),
                      const SizedBox(height: 20),
                      if (!email.endsWith('@kongu.ac.in'))
                        _buildButton(
                          "Register for Event",
                          () => Navigator.pushNamed(
                            context,
                            "/event_registration",
                          ),
                        ),
                      _buildButton(
                        "View Registered Event",
                        () => Navigator.pushNamed(context, "/view_events"),
                      ),
                      _buildButton(
                        "Report",
                        () => Navigator.pushNamed(context, "/report"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 55),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
