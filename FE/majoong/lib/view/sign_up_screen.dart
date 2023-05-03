import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_visibility_provider.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/sign_up_request_dto.dart';
import 'package:majoong/model/request/verify_number_request_dto.dart';
import 'package:majoong/view/pin_number_screen.dart';
import 'package:majoong/viewmodel/signup/sign_up_request_dto_provider.dart';
import 'package:majoong/viewmodel/signup/verify_number_provider.dart';

import '../viewmodel/signup/receive_verification_number_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final verifyNumberState = ref.watch(verifyNumberProvider);
    final signUpState = ref.read(signUpRequestDtoProvider);
    final receiveNumberState = ref.watch(receiveVerificationNumberProvide);

    Future.delayed(Duration.zero, (){
      if (receiveNumberState == 200) {
        showToast(context: context, '인증번호를 전송하였습니다.');
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
      } else if (receiveNumberState == 600) {
        showToast(context: context, '이미 가입된 번호입니다.');
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
      }
      if (verifyNumberState) {
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
        showToast(context: context, '인증되었습니다.');
      } else if(!verifyNumberState && receiveNumberState == 200) {
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
        showToast(
            context: context, '인증번호가 올바르지 않습니다.\n다시 확인해주세요.');
      }
    });

    TextEditingController nicknameController =
        TextEditingController(text: signUpState.nickname);
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController verificationNumberController =
        TextEditingController();
    logger.d(
        'SignUpState : ${signUpState.socialPK}, ${signUpState.profileImage}, ${signUpState.nickname}');
    return DefaultLayout(
      title: '회원가입',
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: BASE_PADDING),
        child: Center(
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(signUpState.profileImage)),
              SizedBox(
                height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
              ),
              Row(
                children: const [
                  Text(
                    '이름',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: BASE_TITLE_FONT_SIZE),
                  ),
                ],
              ),
              const SizedBox(
                height: BASE_MARGIN_TITLE_TO_CONTENT,
              ),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: WHITE_SMOKE,
                    hintText: '이름을 입력하세요',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(
                height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
              ),
              Row(
                children: const [
                  Text(
                    '전화번호',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: BASE_TITLE_FONT_SIZE),
                  ),
                ],
              ),
              const SizedBox(
                height: BASE_MARGIN_TITLE_TO_CONTENT,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: WHITE_SMOKE,
                          hintText: '-를 제외하고 입력하세요',
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide.none),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(loadingVisibilityProvider.notifier).update((state) => true);
                      ref
                          .read(receiveVerificationNumberProvide.notifier)
                          .receiveVerificationNumber(
                              phoneNumberController.text);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: POLICE_MARKER_COLOR,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 60,
                        child: Center(
                          child: Text(
                            '인증번호\n받기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
              ),
              Row(
                children: const [
                  Text(
                    '인증번호 확인',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: BASE_TITLE_FONT_SIZE),
                  ),
                ],
              ),
              const SizedBox(
                height: BASE_MARGIN_TITLE_TO_CONTENT,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: TextField(
                        controller: verificationNumberController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: WHITE_SMOKE,
                          hintText: '인증번호를 입력하세요',
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide.none),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(loadingVisibilityProvider.notifier).update((state) => true);
                      ref
                          .read(verifyNumberProvider.notifier)
                          .verifyNumber(VerifyNumberRequestDto(
                              phoneNumber: phoneNumberController.text,
                              verificationNumber:
                                  verificationNumberController.text));

                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: POLICE_MARKER_COLOR,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 60,
                        child: Center(
                          child: Text(
                            '인증번호\n확인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Spacer(),
              Text('계속하기를 누르면 이용약관 동의로 간주합니다'),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: POLICE_MARKER_COLOR,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: (nicknameController.text.isNotEmpty &&
                              phoneNumberController.text.length == 11 &&
                              verifyNumberState)
                          ? () {
                              final signUpRequestDto =
                                  ref.read(signUpRequestDtoProvider);
                              ref
                                  .read(signUpRequestDtoProvider.notifier)
                                  .update((state) => SignUpRequestDto(
                                      nickname: nicknameController.text,
                                      phoneNumber: phoneNumberController.text,
                                      profileImage:
                                          signUpRequestDto.profileImage,
                                      pinNumber: "",
                                      socialPK: signUpRequestDto.socialPK));

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PinNumberScreen()));
                            }
                          : null,
                      child: Text(
                        '계속하기',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: BASE_TITLE_FONT_SIZE),
                      )),
                ),
              )
            ],
          )),
        ),
      ),
      actions: [],
    );
  }
}
