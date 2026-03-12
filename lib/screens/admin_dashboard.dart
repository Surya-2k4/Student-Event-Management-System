import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/report.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalStudents = 0;
  int totalEvents = 0;
  String userRole = "Staff";
  bool isLoading = true;

  // Professional Theme Colors
  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Use case-insensitive check and trim
      String? role = prefs.getString("role")?.trim();
      userRole = role ?? "Staff";
    });
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final events = await EventService().fetchEvents();
      setState(() {
        totalEvents = events.length;
        totalStudents = events.map((e) => e['email']).toSet().length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = userRole.toLowerCase() == "admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isAdmin ? "Admin Console" : "Staff Console", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                await AuthService().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          )
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildCompactView(isAdmin),
        desktop: _buildWideView(isAdmin),
      ),
    );
  }

  Widget _buildCompactView(bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildStatCards(),
          const SizedBox(height: 30),
          _buildMenuGrid(crossAxisCount: 2, isAdmin: isAdmin),
        ],
      ),
    );
  }

  Widget _buildWideView(bool isAdmin) {
    return Row(
      children: [
        // Sidebar - Professional Drawer Style
        Container(
          width: 280,
          color: primaryDark,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                child: const CircleAvatar(radius: 45, backgroundImage: AssetImage('assets/avatar.png'), backgroundColor: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 15),
              Text(isAdmin ? "Super Admin" : "Staff Member", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(userRole.toUpperCase(), style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white12, indent: 20, endIndent: 20),
              _buildSidebarItem(Icons.dashboard_outlined, "Dashboard", () {}),
              if (isAdmin) _buildSidebarItem(Icons.assessment_outlined, "Reports", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
              if (isAdmin) _buildSidebarItem(Icons.security_outlined, "Credentials", _showManageStaff),
              const Spacer(),
              _buildSidebarItem(Icons.settings_outlined, "System Settings", () {}),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Analytics Overview", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                        ElevatedButton.icon(
                          onPressed: _loadStats,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh Data"),
                          style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildStatCards(isWide: true),
                    const SizedBox(height: 50),
                    const Text("Management Actions", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 20),
                    _buildMenuGrid(crossAxisCount: 4, isAdmin: isAdmin),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      onTap: onTap,
      hoverColor: Colors.white10,
    );
  }

  Widget _buildStatCards({bool isWide = false}) {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _buildStatCard("Platform Registrations", "$totalEvents", Icons.event_note_rounded, const Color(0xFF3B82F6)),
        _buildStatCard("Total Active Students", "$totalStudents", Icons.group_rounded, const Color(0xFFF59E0B)),
        _buildStatCard("System Staff", "Verified", Icons.verified_user_rounded, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuGrid({required int crossAxisCount, required bool isAdmin}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        if (isAdmin) _buildMenuButton("Analytics Reports", Icons.query_stats_rounded, const Color(0xFF6366F1), () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
        if (isAdmin) _buildMenuButton("Credentials Mgmt", Icons.admin_panel_settings_rounded, const Color(0xFF0D9488), _showManageStaff),
        _buildMenuButton("Event Inventory", Icons.inventory_2_rounded, const Color(0xFFF43F5E), () {}),
        _buildMenuButton("System Health", Icons.analytics_rounded, const Color(0xFF8B5CF6), () {}),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showManageStaff() {
    showDialog(
      context: context,
      builder: (context) => const ManageStaffDialog(),
    );
  }
}

class ManageStaffDialog extends StatefulWidget {
  const ManageStaffDialog({super.key});

  @override
  State<ManageStaffDialog> createState() => _ManageStaffDialogState();
}

class _ManageStaffDialogState extends State<ManageStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool isCreating = false;

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isCreating = true);
    final error = await AuthService().createStaff(
      _nameController.text,
      _emailController.text,
      _passController.text,
    );
    
    setState(() => isCreating = false);
    
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff account created!"), backgroundColor: Color(0xFF10B981)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Create Staff Login", style: TextStyle(fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(_nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 15),
              _buildInput(_emailController, "Institutional Email", Icons.email_outlined),
              const SizedBox(height: 15),
              _buildInput(_passController, "Initial Password", Icons.lock_outline, isPass: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: isCreating ? null : _createStaff,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1C2E), padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: isCreating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Establish Account", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0F172A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }
}
