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
  String userRole = "Student";

  // Modern Tech Identity
  final Color bgColor = const Color(0xFFF4F6F9); // Very light grayish blue
  final Color cardColor = Colors.white;
  final Color textPrimary = const Color(0xFF1E293B); // Slate 800
  final Color textSecondary = const Color(0xFF64748B); // Slate 500
  final Color accentBlue = const Color(0xFF3B82F6); // Blue 500
  final Color accentIndigo = const Color(0xFF4F46E5); // Indigo 600

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
      if (mounted) {
        setState(() {
          name = userDetails["name"]!;
          rollNumber = userDetails["rollNumber"]!;
          this.email = userDetails["email"]!;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          name = "";
          rollNumber = "";
          this.email = email;
        });
      }
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
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            "Student Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22),
                tooltip: "Logout",
                onPressed: logout,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accentIndigo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("Quick Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildActionGrid(crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background Tech pattern/gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [accentIndigo.withOpacity(0.8), accentBlue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/avatar.png'),
                        backgroundColor: Color(0xFFE2E8F0),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: accentBlue, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            userRole.toUpperCase(),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  name.isEmpty ? "Student Profile" : name,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(email, style: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 30),
                const Divider(height: 1),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.grid_3x3_rounded, "Roll Number", rollNumber)),
                    Expanded(child: _buildInfoItem(Icons.business_rounded, "Institution", "Kongu Engineering")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: accentIndigo),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? "Not available" : value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActionGrid({required int crossAxisCount}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: crossAxisCount == 1 ? 3 : 0.85,
      children: [
        _buildActionTile(
          "Add Achievement",
          "Document a new event or certification.",
          Icons.rocket_launch_rounded,
          const Color(0xFF3B82F6),
          "/event_registration",
        ),
        _buildActionTile(
          "View History",
          "Check all your past participations.",
          Icons.auto_awesome_mosaic_rounded,
          const Color(0xFF10B981),
          "/view_events",
        ),
        _buildActionTile(
          "Generate Report",
          "Export your record overview.",
          Icons.insert_chart_rounded,
          const Color(0xFF8B5CF6),
          "/report",
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, String route) {
    bool isWide = MediaQuery.of(context).size.width <= 700;
    return InkWell(
      onTap: route.isEmpty ? null : () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(24),
      splashColor: color.withOpacity(0.1),
      highlightColor: color.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: isWide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary)),
                        const SizedBox(height: 6),
                        Text(sub, style: TextStyle(fontSize: 14, color: textSecondary, height: 1.3)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const Spacer(),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textPrimary)),
                  const SizedBox(height: 8),
                  Text(sub, style: TextStyle(fontSize: 14, color: textSecondary, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
