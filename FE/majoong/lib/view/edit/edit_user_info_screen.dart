import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/viewmodel/main/user_info_provider.dart';
import 'package:majoong/viewmodel/signup/verify_number_provider.dart';

import '../../common/component/signle_button_widget.dart';
import '../../common/const/colors.dart';
import '../../common/const/size_value.dart';
import '../../common/layout/default_layout.dart';
import '../../common/layout/loading_visibility_provider.dart';
import '../../common/util/logger.dart';
import '../../model/request/user/verify_number_request_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';
import '../../viewmodel/signup/receive_verification_number_provider.dart';
import '../../viewmodel/signup/sign_up_request_dto_provider.dart';

class EditUserInfoScreen extends ConsumerWidget {
  EditUserInfoScreen({Key? key}) : super(key: key);

  String number = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyNumberState = ref.watch(verifyNumberProvider);
    final userInfoState = ref.read(userInfoProvider);
    final receiveNumberState = ref.watch(receiveVerificationNumberProvide);

    Future.delayed(Duration.zero, () {
      if (receiveNumberState == 200) {
        showToast(context: context, '인증번호를 전송하였습니다.');
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
      } else if (receiveNumberState == 600) {
        showToast(context: context, '이미 가입된 번호입니다.');
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
      }
      if (verifyNumberState == 200) {
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
        showToast(context: context, '인증되었습니다.');
      } else if (verifyNumberState != -1 && verifyNumberState != 200) {
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
        showToast(
            textAlign: TextAlign.center,
            context: context,
            '인증번호가 올바르지 않습니다.\n다시 확인해주세요.');
      }
    });

    if (userInfoState is BaseResponse<UserInfoResponseDto>) {
      TextEditingController nicknameController =
          TextEditingController(text: userInfoState.data!.nickname);
      TextEditingController phoneNumberController =
          TextEditingController(text: userInfoState.data!.phoneNumber);
      TextEditingController verificationNumberController =
          TextEditingController(text: number != "" ? null : number);

      return DefaultLayout(
        title: '회원정보 수정',
        body: Center(
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(children: [
                CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        NetworkImage(userInfoState.data!.profileImage)),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                      onTap: () {
                        //TODO 갤러리 연결
                      },
                      child: Image(image: AssetImage('res/icon_camera.png'), width: 40,)),
                )
              ]),
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
                      ref
                          .read(loadingVisibilityProvider.notifier)
                          .update((state) => true);
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
                      number = verificationNumberController.text;
                      ref.read(verifyNumberProvider.notifier).verifyNumber(
                          VerifyNumberRequestDto(
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
              Spacer(),
              SingleButtonWidget(
                  content: '수정하기',
                  onPressed: (nicknameController.text.isNotEmpty &&
                          phoneNumberController.text.length == 11 &&
                          verifyNumberState == 200)
                      ? () {
                          addButtonClickListener(context);
                        }
                      : null),
              SizedBox(
                height: 10,
              ),
              Text(
                '회원탈퇴',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black54,
                    fontSize: 12),
              )
            ],
          )),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        child: LoadingLayout(),
      );
    }
  }

  addButtonClickListener(BuildContext context) {

  }
}
