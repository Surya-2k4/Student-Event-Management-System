import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';

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
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Portal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildContent(padding: 16),
        desktop: _buildContent(padding: 40, isWide: true),
      ),
    );
  }

  Widget _buildContent({required double padding, bool isWide = false}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildInfoSection()),
                    const SizedBox(width: 30),
                    Expanded(child: _buildActionSection()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 30),
                    _buildActionSection(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.indigoAccent,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoTile(Icons.badge, "Roll Number", rollNumber),
            _buildInfoTile(Icons.school, "Institution", "KEC"),
            _buildInfoTile(Icons.security, "Status", "Student"),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        _buildMenuButton("Register New Event", Icons.add_circle_outline, Colors.indigo, () => Navigator.pushNamed(context, "/event_registration")),
        _buildMenuButton("My Registrations", Icons.list_alt, Colors.blue, () => Navigator.pushNamed(context, "/view_events")),
        _buildMenuButton("Participation Report", Icons.assessment, Colors.purple, () => Navigator.pushNamed(context, "/report")),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: onTap,
      ),
    );
  }
}
