import 'package:flutter/material.dart';
import 'package:majoong/view/splash_screen.dart';

void main() {
  runApp(const Majoong());
}

class Majoong extends StatelessWidget {
  const Majoong({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
