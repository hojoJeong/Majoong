import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/login_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/home_screen.dart';
import 'package:majoong/viewmodel/login/kakao_login_provider.dart';
import 'package:majoong/viewmodel/login/login_provider.dart';
import 'package:majoong/viewmodel/login/login_request_state_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  late User userInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController onBoardingController = PageController();

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

                final kakaoLoginState = ref.watch(kakaoLoginProvider);
                if (kakaoLoginState.value is User) {
                  final socialPK = kakaoLoginState.value!.id.toString();
                  ref
                      .read(loginRequestStateProvider.notifier)
                      .update((state) => LoginRequestDto(socialPK: socialPK));
                  final loginState = ref.watch(loginProvier);
                  if (loginState is BaseResponse<LoginResponseDto>) {
                    final userInfo = loginState.data!;
                    switch (loginState.status) {
                      case 200:
                        {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                          break;
                        }
                      //미가입 회원
                      case 601:
                        {
                          //TODO 회원가입 페이지 이동
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
              },
              child: Image.asset('res/kakao_login_large_wide.png'),
            ),
          ),
        ],
      ),
    );
  }
}
