import 'package:flutter/material.dart';
import 'screens/campus_shared.dart';
import 'screens/login_screen.dart';

void main() => runApp(const CampusConnectApp());

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AtClam',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: C.ink900,
        colorScheme: const ColorScheme.dark(
          primary: C.lime,
          secondary: C.gold,
          surface: C.ink700,
        ),
      ),
      home: const LoginPage(),
    );
  }
}