import 'package:flutter/material.dart';
import 'package:majoong/const/colors.dart';
import 'package:majoong/layout/default_layout.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        backgroundColor: PRIMARY_COLOR,
        child: Container(
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
