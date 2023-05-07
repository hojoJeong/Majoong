import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/request/user/edit_user_info_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/viewmodel/edit/edit_user_info_provider.dart';
import 'package:majoong/viewmodel/main/user_info_provider.dart';
import 'package:majoong/viewmodel/signup/verify_number_provider.dart';

import '../../common/component/signle_button_widget.dart';
import '../../common/const/colors.dart';
import '../../common/const/size_value.dart';
import '../../common/layout/default_layout.dart';
import '../../common/layout/loading_visibility_provider.dart';
import '../../model/request/user/verify_number_request_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';
import '../../viewmodel/signup/receive_verification_number_provider.dart';

class EditUserInfoScreen extends ConsumerStatefulWidget {
  EditUserInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditUserInfoState();
}

class _EditUserInfoState extends ConsumerState<EditUserInfoScreen> {
  String? imageByString;
  File? imageByFile;
  String nickname = "";
  String phoneNumber = "";
  String? verificationNumber;

  final imagePicker = ImagePicker();

  Future getImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageByFile = File(XFile(pickedFile.path).path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyNumberState = ref.watch(verifyNumberProvider);
    final editUserInfoState = ref.watch(editUserInfoProvider);
    final userInfoState = ref.read(userInfoProvider);
    final receiveNumberState = ref.watch(receiveVerificationNumberProvide);
    final userInfo =
        ref.read(userInfoProvider) as BaseResponse<UserInfoResponseDto>;
    imageByString = editUserInfoState is BaseResponse<EditUserInfoRequestDto>
        ? null
        : userInfo.data!.profileImage;
    imageByFile = editUserInfoState is BaseResponse<EditUserInfoRequestDto>
        ? editUserInfoState.data!.profileImage
        : null;
    nickname = editUserInfoState is BaseResponse<EditUserInfoRequestDto>
        ? editUserInfoState.data!.nickname
        : userInfo.data!.nickname;
    phoneNumber = editUserInfoState is BaseResponse<EditUserInfoRequestDto>
        ? editUserInfoState.data!.phoneNumber
        : userInfo.data!.phoneNumber;

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
      if (editUserInfoState is BaseResponse &&
          editUserInfoState.status == 200) {
        showToast(context: context, '회원 정보가 수정되었습니다.');
        Navigator.pop(context);
      }
    });

    if (userInfoState is BaseResponse<UserInfoResponseDto>) {
      TextEditingController nicknameController =
          TextEditingController(text: nickname);
      TextEditingController phoneNumberController =
          TextEditingController(text: phoneNumber);
      TextEditingController verificationNumberController =
          TextEditingController(text: verificationNumber);

      return DefaultLayout(
        title: '회원정보 수정',
        body: Center(
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(children: [
                CircleAvatar(
                    radius: 80,
                    backgroundImage:  imageByFile == null
                        ? NetworkImage(userInfoState.data!.profileImage)
                        : Image.file(imageByFile!).image),

                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Image(
                        image: AssetImage('res/icon_camera.png'),
                        width: 40,
                      )),
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
                  onEditingComplete: () {
                    nickname = nicknameController.text;
                  },
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
                        onEditingComplete: () {
                          phoneNumber = phoneNumberController.text;
                        },
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
                      final editUserInfo = EditUserInfoRequestDto(
                          nickname: nickname,
                          phoneNumber: phoneNumber,
                          profileImage: imageByFile);
                      ref
                          .read(editUserInfoProvider.notifier)
                          .updateState(editUserInfo);

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
                      final editUserInfo = EditUserInfoRequestDto(
                          nickname: nickname,
                          phoneNumber: phoneNumber,
                          profileImage: imageByFile);
                      ref
                          .read(editUserInfoProvider.notifier)
                          .updateState(editUserInfo);

                      verificationNumber = verificationNumberController.text;
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
    final request = ref.read(editUserInfoProvider) as BaseResponse<EditUserInfoRequestDto>;
    ref.read(editUserInfoProvider.notifier).editUserInfo(request.data!);
  }
}
