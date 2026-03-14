import 'package:flutter/material.dart';
import 'package:flutter_auth/services/auth_services.dart';
<<<<<<< Updated upstream
import 'login_screen.dart';
=======
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> Stashed changes

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

<<<<<<< Updated upstream
class _RegisterScreenState extends State<RegisterScreen> {
=======
class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
>>>>>>> Stashed changes
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
<<<<<<< Updated upstream
=======
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue

  @override
  void initState() {
    super.initState();
    _checkSession();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final role = prefs.getString("role")?.toLowerCase() ?? "";
    
    if (token.isNotEmpty && mounted) {
      String targetRoute = (role == "admin" || role == "staff") ? "/admin" : "/user_screen";
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    rollNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
>>>>>>> Stashed changes

  void register() async {
    if (!emailController.text.endsWith('@kongu.edu')) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< Updated upstream
        SnackBar(content: Text("Gmail must be in the format of @kongu.edu")),
=======
        const SnackBar(
          content: Text("Please use your institutional @kongu.edu or @kongu.ac.in email"),
          behavior: SnackBarBehavior.floating,
        ),
>>>>>>> Stashed changes
      );
      return;
    }

    String? error = await authService.register(
      nameController.text,
      rollNumberController.text,
      emailController.text,
      passwordController.text,
    );
    if (!mounted) return;
    if (error == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Successful"),
            content: Text(
              "Welcome, ${nameController.text}! You have been registered successfully.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ); // Go back to login
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
<<<<<<< Updated upstream
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Failed"),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
=======
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
>>>>>>> Stashed changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: Colors.grey[200], // Light-themed background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rectangular Image with Stylish Border
                  Container(
                    width: 250,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/mca.png', // Make sure you add an image to assets
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // KEC SEMS Text
                  const Text(
                    "KEC_SEMS",
                    style: TextStyle(
                      fontSize: 20, // Slightly larger for emphasis
                      fontWeight: FontWeight.w900, // Extra bold for impact
                      color: Colors.blueAccent,
                      letterSpacing: 1.5, // Adds spacing for a premium look
                      wordSpacing: 2, // More spacing between words
                      fontFamily: 'Roboto', // Custom font for a modern touch
                      shadows: [
                        Shadow(
                          color: Colors.black26, // Subtle text shadow
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Welcome Text
                  const Text(
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Register to get started",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  // Name Field
                  _buildTextField(
                    controller: nameController,
                    label: "Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),
                  // Roll Number Field
                  _buildTextField(
                    controller: rollNumberController,
                    label: "Roll Number",
                    icon: Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 15),
                  // Email Field
                  _buildTextField(
                    controller: emailController,
                    label: "Gmail",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 15),
                  // Password Field
                  _buildTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
=======
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ResponsiveLayout(
                        mobile: _buildCompactContent(),
                        desktop: _buildWideContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/auth_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            primaryDark.withOpacity(0.85),
            BlendMode.srcOver,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBranding(isCompact: true),
          const SizedBox(height: 32),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildWideContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      height: 650,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryDark, const Color(0xFF1E293B)],
                ),
              ),
              child: _buildBranding(isCompact: false),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Apply for Portal", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const Text("Start your achievement journey", 
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding({required bool isCompact}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(isCompact ? 0.1 : 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.rocket_launch_rounded, 
            size: 35, color: isCompact ? primaryDark : accentColor),
        ),
        const SizedBox(height: 20),
        Text("Join SEMS", 
          style: TextStyle(
            color: isCompact ? primaryDark : Colors.white, 
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text("Register to track your professional growth.", 
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCompact ? Colors.grey[600] : Colors.white70, 
              fontSize: 13, 
              fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildInput(nameController, "Full Legal Name", Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _buildInput(rollNumberController, "Roll Number/ID", Icons.badge_outlined),
          const SizedBox(height: 12),
          _buildInput(emailController, "Institutional Email", Icons.alternate_email_rounded),
          const SizedBox(height: 12),
          _buildInput(passwordController, "Secure Password", Icons.lock_outline_rounded, isPass: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Enroll in Portal", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
            child: Text("Existing member? Access Here", 
              style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
>>>>>>> Stashed changes
      ),
    );
  }

<<<<<<< Updated upstream
  // 🎨 Custom TextField with modern styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
=======
  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: isPass,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
          ),
          validator: (v) => v!.isEmpty ? "Mandatory field" : null,
        ),
      ],
>>>>>>> Stashed changes
    );
  }
}

