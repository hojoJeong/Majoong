import 'package:flutter/material.dart';
import 'package:toonflix/screens/toonflix_home_screen.dart';

class Toonflix extends StatelessWidget {
  const Toonflix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToonflixHomeScreen(),
    );
  }
}
