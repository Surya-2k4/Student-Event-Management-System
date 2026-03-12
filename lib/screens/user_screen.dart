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
<<<<<<< Updated upstream
=======
  String userRole = "Student";

  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue
>>>>>>> Stashed changes

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "User Profile",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
<<<<<<< Updated upstream
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          automaticallyImplyLeading: false, // Prevent back button
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 254, 253, 253),
=======
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            child: const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/avatar.png'), backgroundColor: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 20),
          Text(name.isEmpty ? "Student Name" : name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 5),
          Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Digital Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const Divider(height: 30),
          _buildInfoItem(Icons.badge_outlined, "Roll Number", rollNumber),
          _buildInfoItem(Icons.domain_rounded, "Institution", "Kongu Engineering"),
          _buildInfoItem(Icons.verified_user_outlined, "Verified Account", userRole),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: primaryDark)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value.isEmpty ? "Not Available" : value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionGrid({required int crossAxisCount}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: crossAxisCount == 1 ? 4 : 2,
      children: [
        _buildActionTile("Add Achievement", "Document a new event", Icons.add_task_rounded, const Color(0xFF3B82F6), "/event_registration"),
        _buildActionTile("View History", "Check past participations", Icons.history_edu_rounded, const Color(0xFF10B981), "/view_events"),
        _buildActionTile("Generate Report", "Export record overview", Icons.summarize_rounded, const Color(0xFF8B5CF6), "/report"),
      ],
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, String route) {
    return InkWell(
      onTap: route.isEmpty ? null : () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                  Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
>>>>>>> Stashed changes
              ),
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
