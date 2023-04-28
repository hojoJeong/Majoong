import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController onBoardingController = PageController();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: POLICE_MARKER_COLOR),
            height: MediaQuery.of(context).size.height * 0.7, // 필요한 높이를 지정
            child: PageView(
              controller: onBoardingController,
              children: [
                Image.asset('res/onboarding1.png'),
                Image.asset('res/onboarding2.png'),
                Image.asset('res/onboarding3.png'),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: GAINSBORO,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmoothPageIndicator(
                controller: onBoardingController,
                count: 3,
                effect: const WormEffect(
                    activeDotColor: POLICE_MARKER_COLOR,
                    dotColor: TEXT_HINT_COLOR,
                    dotHeight: 6,
                    dotWidth: 6),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                /** 카카오 로그인 API 호출 */
                loginKakao();
              },
              child: Column(
                children: [
                  Image.asset('res/kakao_login_large_wide.png'),
                  CheckboxListTileFormField(
                    title: const Text(
                      '자동 로그인',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (bool? value) {},
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loginKakao() async {
    if (await isKakaoTalkInstalled()) {
      print('카카오톡 설치 됨');
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      print('카카오톡 설치 안됨');
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    User user;
    try {
      user = await UserApi.instance.me();
      print(user);
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return;
    }
  }
}
