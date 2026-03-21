import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wics_hackathon_2026/pages/login_signup.dart';
import 'package:wics_hackathon_2026/pages/introduction_screens/hero.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => HeroScreen(
          onNext: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
    );
  }
}
