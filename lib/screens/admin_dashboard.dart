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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "Staff";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildCompactView(),
        desktop: _buildWideView(),
      ),
    );
  }

  Widget _buildCompactView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatCards(),
          const SizedBox(height: 20),
          _buildMenuGrid(crossAxisCount: 2),
        ],
      ),
    );
  }

  Widget _buildWideView() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          color: Colors.grey[100],
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(radius: 40, backgroundColor: Colors.indigo, child: Icon(Icons.person, color: Colors.white, size: 40)),
              const SizedBox(height: 10),
              const Text("Management Console", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ListTile(leading: const Icon(Icons.dashboard), title: const Text("Dashboard"), onTap: () {}),
              ListTile(leading: const Icon(Icons.assessment), title: const Text("Reports"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
              if (userRole == "Admin")
                ListTile(leading: const Icon(Icons.vpn_key), title: const Text("Manage Staff"), onTap: _showManageStaff),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildStatCards(isWide: true),
                const SizedBox(height: 40),
                const Text("Quick Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildMenuGrid(crossAxisCount: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards({bool isWide = false}) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildStatCard("Total Registrations", "$totalEvents", Icons.event_available, Colors.blue),
        _buildStatCard("Unique Students", "$totalStudents", Icons.people, Colors.orange),
        _buildStatCard("Staff Accounts", "Active", Icons.verified_user, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuGrid({required int crossAxisCount}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildMenuButton("Student Reports", Icons.assessment, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Report()))),
        if (userRole == "Admin")
          _buildMenuButton("Manage Staff", Icons.vpn_key, Colors.teal, _showManageStaff),
        _buildMenuButton("Export Data", Icons.download, Colors.brown, () {}),
        _buildMenuButton("Settings", Icons.settings, Colors.blueGrey, () {}),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff account created successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Staff Account"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Staff Name"), validator: (v) => v!.isEmpty ? "Required" : null),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Staff Email"), validator: (v) => v!.isEmpty ? "Required" : null),
            TextFormField(controller: _passController, decoration: const InputDecoration(labelText: "Password"), obscureText: true, validator: (v) => v!.length < 6 ? "Min 6 chars" : null),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isCreating ? null : _createStaff,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: isCreating ? const CircularProgressIndicator(color: Colors.white) : const Text("Create"),
        ),
      ],
    );
  }
}
