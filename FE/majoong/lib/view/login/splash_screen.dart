import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/main/main_screen.dart';
import 'package:majoong/view/login/login_screen.dart';
import 'package:majoong/viewmodel/login/check_auto_login_provider.dart';
import 'package:majoong/viewmodel/login/login_provider.dart';
import '../../common/const/colors.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkAutoLoginState = ref.watch(checkAutoLoginProvider);
    final autoLoginState = ref.watch(loginProvider);
    if (checkAutoLoginState) {
      ref.read(loginProvider.notifier).login(null);
      if (autoLoginState is BaseResponse && autoLoginState.status == 200) {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        });
      }
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
    }

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
      ),
    );
  }
}
