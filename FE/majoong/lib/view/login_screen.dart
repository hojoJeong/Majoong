import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter/material.dart';
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
}
