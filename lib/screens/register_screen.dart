import 'package:flutter/material.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  final Color primaryDark = const Color(0xFF1A1C2E);
  final Color accentColor = const Color(0xFF2DD4BF);

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!emailController.text.trim().endsWith('@kongu.edu') && !emailController.text.trim().endsWith('@kongu.ac.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please use your institutional @kongu.edu or @kongu.ac.in email")),
      );
      return;
    }

    setState(() => isLoading = true);
    String? error = await authService.register(
      nameController.text.trim(),
      rollNumberController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (!mounted) return;
    if (error == null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Your student account has been established. You may now authenticate."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/login");
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            child: const Text("Proceed to Login", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
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
            children: [
              const SizedBox(height: 50),
              _buildHeading(),
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
        // Sidebar Branding
        Expanded(
          flex: 1,
          child: Container(
            color: primaryDark,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch_outlined, size: 80, color: Color(0xFF2DD4BF)),
                const SizedBox(height: 30),
                const Text("Join KEC SEMS", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Text("Register to document your achievements and track your professional growth within the institution.", 
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
        // Form Content
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Text("Start your achievement journey today", style: TextStyle(color: Colors.grey, fontSize: 16)),
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

  Widget _buildHeading() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: primaryDark.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(Icons.person_add_rounded, size: 50, color: primaryDark),
        ),
        const SizedBox(height: 15),
        const Text("Student Registration", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildInput(nameController, "Full Legal Name", Icons.person_outline),
          const SizedBox(height: 15),
          _buildInput(rollNumberController, "Roll Number/ID", Icons.badge_outlined),
          const SizedBox(height: 15),
          _buildInput(emailController, "Institutional Email", Icons.email_outlined),
          const SizedBox(height: 15),
          _buildInput(passwordController, "Strong Password", Icons.lock_outline, isPass: true),
          const SizedBox(height: 35),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Complete Registration", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
            child: Text("Already registered? Login", style: TextStyle(color: primaryDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
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
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }
}
