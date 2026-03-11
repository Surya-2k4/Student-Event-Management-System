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
  String userRole = "Student";

  final Color primaryDark = const Color(0xFF1A1C2E);
  final Color accentColor = const Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString("email") ?? "";
    final storedRole = prefs.getString("role") ?? "Student";
    
    setState(() {
      email = storedEmail;
      userRole = storedRole;
    });

    final userDetails = await AuthService().fetchUserDetails(storedEmail);
    if (userDetails != null) {
      if (mounted) {
        setState(() {
          name = userDetails["name"]!;
          rollNumber = userDetails["rollNumber"]!;
        });
      }
    }
  }

  void logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Student Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout_rounded, color: Colors.white)),
          const SizedBox(width: 10),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildContent(padding: 20),
        desktop: _buildContent(padding: 40, isWide: true),
      ),
    );
  }

  Widget _buildContent({required double padding, bool isWide = false}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildInfoCard()),
                    const SizedBox(width: 30),
                    Expanded(flex: 3, child: _buildActionGrid(crossAxisCount: 2)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 30),
                    _buildActionGrid(crossAxisCount: 1),
                  ],
                ),
            ],
          ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            child: const CircleAvatar(radius: 50, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.person, size: 50, color: Colors.white)),
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
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Digital Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const Divider(height: 30),
          _buildInfoItem(Icons.badge_outlined, "Roll No", rollNumber),
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
        _buildActionTile("Generate Summary", "Export record overview", Icons.summarize_rounded, const Color(0xFF8B5CF6), "/report"),
        _buildActionTile("Privacy Settings", "Manage account visibility", Icons.privacy_tip_rounded, const Color(0xFF64748B), ""),
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
          border: Border.all(color: Colors.grey[100]!),
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
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
