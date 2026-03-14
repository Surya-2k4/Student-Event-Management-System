import 'package:flutter/material.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Validate email format
    if (!email.endsWith('@kongu.edu') && !email.endsWith('@kongu.ac.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email must be in the format @kongu.edu or @kongu.ac.in',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String? error = await authService.login(email, password);
    if (!mounted) return;
    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Animation/Image
          _buildBackground(),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
      height: 550,
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
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome Back", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const Text("Sign in to your dashboard", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 32),
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
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(isCompact ? 0.1 : 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school_rounded, 
            size: 40, color: isCompact ? primaryDark : accentColor),
        ),
        const SizedBox(height: 24),
        Text("KEC SEMS", 
          style: TextStyle(
            color: isCompact ? primaryDark : Colors.white, 
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text("Management Portal", 
          style: TextStyle(
            color: isCompact ? Colors.grey[600] : Colors.white70, 
            fontSize: 14, 
            fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInputField(emailController, "Institutional Email", Icons.alternate_email_rounded),
        const SizedBox(height: 20),
        _buildInputField(passwordController, "Secure Password", Icons.lock_outline_rounded, isPass: true),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Authenticate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("New to the system?", style: TextStyle(color: Colors.grey[600])),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: isPass,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
          ),
        ),
      ],
    );
  }
}

