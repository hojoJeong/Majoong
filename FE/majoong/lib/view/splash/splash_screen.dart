import 'package:flutter/material.dart';
import '../../common/const/colors.dart';
import '../../common/layout/default_layout.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: PRIMARY_COLOR,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'res/majoong_logo.jpg',
                ),
                fit: BoxFit.cover),
          ),
        ));
  }
}
