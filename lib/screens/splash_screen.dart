import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller and animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the animation
    _controller.forward();

    // Check for existing session and navigate accordingly
    Timer(const Duration(milliseconds: 2500), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final role = prefs.getString("role")?.toLowerCase() ?? "";

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // Authenticated session found - force navigation to respective dashboard
        String targetRoute = (role == "admin" || role == "staff") ? "/admin" : "/user_screen";
        Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
      } else {
        // No session, go to login
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(_animation),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/kec_logo.png', width: 160, height: 160),
                const SizedBox(height: 30),
                const Text("KEC SEMS", 
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w900, 
                    color: Color(0xFF0F172A),
                    letterSpacing: 2
                  )),
                const SizedBox(height: 8),
                Text("Student Event Management System", 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500, 
                    color: Colors.grey[600],
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
