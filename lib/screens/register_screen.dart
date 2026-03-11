import 'package:flutter/material.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'login_screen.dart';

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

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Allow both kongu domains
    if (!emailController.text.endsWith('@kongu.edu') && !emailController.text.endsWith('@kongu.ac.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please use your institutional @kongu.edu or @kongu.ac.in email")),
      );
      return;
    }

    setState(() => isLoading = true);
    String? error = await authService.register(
      nameController.text,
      rollNumberController.text,
      emailController.text,
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
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Account created! You can now log in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/login");
            },
            child: const Text("Login Now"),
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
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildBrand(),
            const SizedBox(height: 40),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildWideView() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.indigo,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text("KEC SEMS", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                const Text("Join our achievement network", style: TextStyle(color: Colors.white70, fontSize: 18)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(60.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person_add, size: 50, color: Colors.indigo),
        ),
        const SizedBox(height: 20),
        const Text("Student Registration", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(nameController, "Full Name", Icons.person),
          const SizedBox(height: 15),
          _buildTextField(rollNumberController, "Roll Number", Icons.badge),
          const SizedBox(height: 15),
          _buildTextField(emailController, "Institutional Email", Icons.email),
          const SizedBox(height: 15),
          _buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
          const SizedBox(height: 30),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create Account", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
            child: const Text("Already have an account? Login", style: TextStyle(color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }
}
