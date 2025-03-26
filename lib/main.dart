import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/user_screen.dart';
import 'package:flutter_auth/screens/event_registration.dart';
import 'package:flutter_auth/screens/login_screen.dart';
import 'package:flutter_auth/screens/register_screen.dart';
import 'package:flutter_auth/screens/report.dart';
import 'package:flutter_auth/screens/view_events.dart';
import 'package:flutter_auth/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
