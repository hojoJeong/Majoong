import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/verify_number_request_dto.dart';
import 'package:majoong/view/pin_number_screen.dart';
import 'package:majoong/viewmodel/login/sign_up_provider.dart';
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
    final signUpState = ref.read(signUpProvider);
    TextEditingController nicknameController =
        TextEditingController(text: signUpState.nickname);
    TextEditingController phoneNumberController =
        TextEditingController();
    TextEditingController verificationNumberController =
        TextEditingController();
    logger.d(
        'SignUpState : ${signUpState.socialPK}, ${signUpState.profileImage}, ${signUpState.nickname}');
    return DefaultLayout(
        title: '회원가입',
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: BASE_PADDING),
            child: Center(
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  TextField(
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
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(receiveVerificationNumberProvide.notifier)
                              .receiveVerificationNumber(phoneNumberController.text);
                          ref.listen(receiveVerificationNumberProvide,
                              (previous, next) {
                            if (next) {
                              showToast(context: context, '인증번호를 전송하였습니다.');
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: POLICE_MARKER_COLOR,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final response = await ref
                              .read(verifyNumberProvider.notifier)
                              .verifyNumber(VerifyNumberRequestDto(
                                  phoneNumber: phoneNumberController.text,
                                  verificationNumber:
                                      verificationNumberController.text));
                          if (response) {
                            showToast(context: context, '인증되었습니다.');
                          } else {
                            showToast(
                                context: context,
                                '인증번호가 올바르지 않습니다.\n다시 확인해주세요.');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: POLICE_MARKER_COLOR,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('계속하기를 누르면 이용약관 동의로 간주합니다'),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: POLICE_MARKER_COLOR,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: verifyNumberState ? () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PinNumberScreen()));
                        } : null,
                        child: Text(
                          '계속하기',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              )),
            ),
          ),
        ),
        actions: []);
  }
}
