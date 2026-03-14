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

  // Modern Tech Palette
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color primaryDark = const Color(0xFF0F172A);
  final Color secondaryDark = const Color(0xFF1E293B);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color accentIndigo = const Color(0xFF4F46E5);
  final Color textPrimary = const Color(0xFF1E293B);
  final Color textSecondary = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        String? role = prefs.getString("role")?.trim();
        userRole = role ?? "Staff";
      });
    }
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final events = await EventService().fetchEvents();
      if (mounted) {
        setState(() {
          totalEvents = events.length;
          totalStudents = events.map((e) => e['email']).toSet().length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = userRole.toLowerCase() == "admin";

    return Scaffold(
      backgroundColor: bgColor,
      body: ResponsiveLayout(
        mobile: _buildCompactView(isAdmin),
        desktop: _buildWideView(isAdmin),
      ),
    );
  }

  // --- COMPACT VIEW ---
  Widget _buildCompactView(bool isAdmin) {
    return Column(
      children: [
        AppBar(
          title: Text(
            isAdmin ? "Admin Console" : "Staff Console",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          centerTitle: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryDark, secondaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                await AuthService().logout();
                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Overview", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary)),
                    IconButton(icon: Icon(Icons.refresh_rounded, color: accentBlue), onPressed: _loadStats),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatCards(isWide: false),
                const SizedBox(height: 35),
                Text("Portal Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                _buildMenuGrid(crossAxisCount: 2, isAdmin: isAdmin),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDE VIEW ---
  Widget _buildWideView(bool isAdmin) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryDark, secondaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(5, 0))],
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [accentIndigo, accentBlue]),
                ),
                child: const CircleAvatar(radius: 45, backgroundImage: AssetImage('assets/avatar.png'), backgroundColor: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 20),
              Text(
                isAdmin ? "Super Admin" : "Staff Member",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: accentBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(userRole.toUpperCase(), style: TextStyle(color: accentBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white12, indent: 24, endIndent: 24),
              const SizedBox(height: 20),
              _buildSidebarItem(Icons.dashboard_rounded, "Dashboard", () {}, isActive: true),
              if (isAdmin) _buildSidebarItem(Icons.assessment_rounded, "Analytics Reports", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
              if (isAdmin) _buildSidebarItem(Icons.admin_panel_settings_rounded, "Staff Credentials", _showManageStaff),
              _buildSidebarItem(Icons.inventory_2_rounded, "Event Master Data", () {}),
              const Spacer(),
              _buildSidebarItem(Icons.logout_rounded, "Secure Logout", () async {
                await AuthService().logout();
                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }, highlight: true),
              const SizedBox(height: 30),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(50.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Workspace Overview", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1.0)),
                          const SizedBox(height: 8),
                          Text("Monitor platform activity and system metrics.", style: TextStyle(fontSize: 16, color: textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: accentBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loadStats,
                          icon: const Icon(Icons.sync_rounded, size: 20, color: Colors.white),
                          label: const Text("Sync Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildStatCards(isWide: true),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Container(width: 4, height: 24, decoration: BoxDecoration(color: accentIndigo, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 12),
                      Text("Administrative Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuGrid(crossAxisCount: 3, isAdmin: isAdmin),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap, {bool isActive = false, bool highlight = false}) {
    Color itemColor = highlight ? Colors.redAccent : (isActive ? Colors.white : Colors.white60);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: Colors.white24) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: itemColor, size: 22),
                const SizedBox(width: 16),
                Text(title, style: TextStyle(color: itemColor, fontSize: 15, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500)),
                if (isActive) const Spacer(),
                if (isActive) Container(width: 6, height: 6, decoration: BoxDecoration(color: accentBlue, shape: BoxShape.circle))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards({required bool isWide}) {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _buildStatCard("Platform Records", "$totalEvents", Icons.description_rounded, accentIndigo, isWide ? 340 : double.infinity),
        _buildStatCard("Active Students", "$totalStudents", Icons.school_rounded, const Color(0xFF10B981), isWide ? 340 : double.infinity),
        _buildStatCard("System Staff", "Verified", Icons.admin_panel_settings_rounded, const Color(0xFFF59E0B), isWide ? 340 : double.infinity),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 30),
              ),
              Icon(Icons.auto_graph_rounded, color: Colors.grey.shade300, size: 28),
            ],
          ),
          const SizedBox(height: 25),
          Text(value, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: textPrimary, height: 1.0, letterSpacing: -1.5)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuGrid({required int crossAxisCount, required bool isAdmin}) {
    List<Widget> actions = [
      if (isAdmin) _buildMenuButton("Insight Engine", "View global analytics", Icons.query_stats_rounded, const Color(0xFF6366F1), () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
      if (isAdmin) _buildMenuButton("Access Gateway", "Manage permissions", Icons.key_rounded, const Color(0xFF0D9488), _showManageStaff),
      _buildMenuButton("Data Vault", "Browse submissions", Icons.inventory_2_rounded, const Color(0xFFF43F5E), () {}),
      _buildMenuButton("System Health", "Platform diagnostics", Icons.analytics_rounded, const Color(0xFF8B5CF6), () {}),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: crossAxisCount == 2 ? 1 : 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }

  Widget _buildMenuButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: color.withOpacity(0.1),
      highlightColor: color.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showManageStaff() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
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
    if (!mounted) return;
    
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("Staff Access Provisioned", style: TextStyle(fontWeight: FontWeight.bold))]),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: const Offset(0, 10))]),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  const Text("Provision Core Access", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                ],
              ),
              const SizedBox(height: 30),
              _buildInput(_nameController, "Operative Name", Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildInput(_emailController, "Vetted Email Address", Icons.alternate_email_rounded),
              const SizedBox(height: 16),
              _buildInput(_passController, "Security Key", Icons.password_rounded, isPass: true),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                    child: const Text("Abort", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isCreating ? null : _createStaff,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isCreating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Deploy Staff Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(18),
      ),
      validator: (v) => v!.isEmpty ? "Input imperative" : null,
    );
  }
}
