import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/login_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/home_screen.dart';
import 'package:majoong/viewmodel/login/login_provider.dart';
import 'package:majoong/viewmodel/login/login_request_state_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    final PageController onBoardingController = PageController();

    final socialPk = ref.watch(loginRequestStateProvider);
    logger.d('social pk : ${socialPk.socialPK}');
    if (socialPk.socialPK != '-1') {
      login();
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: POLICE_MARKER_COLOR),
            height: MediaQuery.of(context).size.height * 0.8, // 필요한 높이를 지정
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
                const CircularProgressIndicator();
                loginKakao();
              },
              child: Image.asset('res/kakao_login_large_wide.png'),
            ),
          ),
        ],
      ),
    );
  }

  login() {
    final loginState = ref.watch(loginProvier);
    logger.d('login Api call, login response Status(0이면 초기값) : $loginState');
    if (loginState != 0) {
      logger.d('login response : $loginState');
      switch (loginState) {
        case 200:
          {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            break;
          }
        //미가입 회원
        case 601:
          {
            //TODO 회원가입 페이지 이동
            logger.d('미가입 회원 : $loginState');
            break;
          }
        //탈퇴 회원
        case 602:
          {
            showToast("이미 탈퇴한 회원입니다.",
                animation: StyledToastAnimation.slideFromBottom);
          }
      }
    }
  }

  loginKakao() async {
    User user;
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

    try {
      user = await UserApi.instance.me();
      print('user info : $user');
      final socialPK = user.id.toString();
      print('socialPK : $socialPK');
      ref
          .read(loginRequestStateProvider.notifier)
          .update((state) => LoginRequestDto(socialPK: socialPK));
      return user;
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return;
    }
  }
}
