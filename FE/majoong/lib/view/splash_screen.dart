import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/view/login_screen.dart';
import 'package:majoong/viewmodel/check_auto_login_provider.dart';
import '../common/const/colors.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkAutoLoginState = ref.watch(checkAutoLoginProvider);
    logger.d('checkAutoLoginState : $checkAutoLoginState');
    if (checkAutoLoginState) {
      print('autologin');
      // ref.listen(autoLoginProvider, (_, next) {
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => HomeScreen()));
      // });
    } else {
      print('not autologin');
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

        // autoLoginState.when(
        //     data: (data) {
        //       if (data) {
        //         loginState.when(
        //             data: (data) {
        //               Future.delayed(Duration(seconds: 2), () {
        //                 //TODO 로그인 성공 시 메인화면으로 이동
        //
        //               });
        //             },
        //             error: (e, stack) {
        //               print(e);
        //             },
        //             loading: () {});
        //       } else {
        //         Future.delayed(Duration(seconds: 2), () {
        //           Navigator.pushReplacement(context,
        //               MaterialPageRoute(builder: (context) => LoginScreen()));
        //         });
        //       }
        //     },
        //     error: (e, stack) {},
        //     loading: () {}),
      ),
    );
  }
}
