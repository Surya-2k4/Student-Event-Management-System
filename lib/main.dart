import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/user_screen.dart';
import 'package:flutter_auth/screens/event_registration.dart';
import 'package:flutter_auth/screens/login_screen.dart';
import 'package:flutter_auth/screens/register_screen.dart';
import 'package:flutter_auth/screens/report.dart';
import 'package:flutter_auth/screens/view_events.dart';
import 'package:flutter_auth/screens/splash_screen.dart';
import 'package:flutter_auth/screens/admin_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KEC SEMS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1C2E),
          primary: const Color(0xFF1A1C2E),
          secondary: const Color(0xFF2DD4BF),
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Modern font if available
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user_screen': (context) => const UserScreen(),
        '/event_registration': (context) => const EventRegistration(),
        '/view_events': (context) => const ViewEvents(),
        '/report': (context) => const Report(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}
