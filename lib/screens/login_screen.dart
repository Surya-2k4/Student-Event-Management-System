import 'package:flutter/material.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  final Color primaryDark = const Color(0xFF1A1C2E);
  final Color accentColor = const Color(0xFF2DD4BF);

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);
    String? error = await authService.login(email, password);
    setState(() => isLoading = false);

    if (!mounted) return;
    if (error == null) {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString("role")?.toLowerCase() ?? "student";

      if (role == "admin" || role == "staff") {
        Navigator.pushReplacementNamed(context, "/admin");
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        mobile: _buildCompactView(),
        desktop: _buildWideView(),
      ),
    );
  }

  Widget _buildCompactView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideView() {
    return Row(
      children: [
        // Branding Banner
        Expanded(
          flex: 1,
          child: Container(
            color: primaryDark,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 100, color: Color(0xFF2DD4BF)),
                const SizedBox(height: 20),
                const Text("KEC SEMS", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Text("Student Event Management System", style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
        // Login Content
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Text("Enter your credentials to manage records", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 40),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: primaryDark.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(Icons.lock_person_outlined, size: 60, color: primaryDark),
        ),
        const SizedBox(height: 20),
        const Text("Portal Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInputField(emailController, "Institutional Email", Icons.alternate_email_rounded),
        const SizedBox(height: 20),
        _buildInputField(passwordController, "Secure Password", Icons.password_rounded, isPass: true),
        const SizedBox(height: 40),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Authenticate Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, "/register"),
          child: Text("Don't have an account? Join SESM", style: TextStyle(color: primaryDark, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryDark),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }
}
