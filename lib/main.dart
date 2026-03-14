import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/user_screen.dart';
import 'package:flutter_auth/screens/event_registration.dart';
import 'package:flutter_auth/screens/login_screen.dart';
import 'package:flutter_auth/screens/register_screen.dart';
import 'package:flutter_auth/screens/report.dart';
import 'package:flutter_auth/screens/view_events.dart';
import 'package:flutter_auth/screens/splash_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
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
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF3B82F6), // Blue 500
          background: const Color(0xFFF8FAFC), // Slate 50
          surface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF334155),
          displayColor: const Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_screen': (context) => UserScreen(),
        '/event_registration': (context) => EventRegistration(),
        '/view_events': (context) => ViewEvents(),
        '/report': (context) => Report(),
      },
    );
  }
}
