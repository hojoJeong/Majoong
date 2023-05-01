import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/home_screen.dart';
import 'package:majoong/view/login_screen.dart';
import 'package:majoong/viewmodel/login/auto_login_provider.dart';
import 'package:majoong/viewmodel/login/check_auto_login_provider.dart';
import 'package:majoong/viewmodel/login/login_provider.dart';
import '../common/const/colors.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkAutoLoginState = ref.watch(checkAutoLoginProvider);
    if (checkAutoLoginState) {
      final autoLoginState = ref.watch(autoLoginProvider);
      if (autoLoginState is BaseResponse<LoginResponseDto>) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
