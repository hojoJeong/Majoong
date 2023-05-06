import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:majoong/common/component/signle_button_widget.dart';

import '../../common/const/size_value.dart';
import '../../common/layout/default_layout.dart';

class EditPinNumberScreen extends ConsumerStatefulWidget {
  const EditPinNumberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditPinNumberState();
}

class _EditPinNumberState extends ConsumerState<EditPinNumberScreen> {
  bool _onEditing = true;
  String? _code = "";

  @override
  Widget build(BuildContext context) {
    // final signUpState = ref.watch(signUpProvider);
    // if (signUpState) {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     showToast(context: context, 'PIN 번호가 수정되었습니다.');
    //     Navigator.pop(context);
    //   });
    // }
    return DefaultLayout(
      title: 'PIN 번호 수정',
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: BASE_PADDING),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '경찰 신고 취소 등\n오작동 방지용으로 사용됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: BASE_TITLE_FONT_SIZE, color: Colors.black),
              ),
              const SizedBox(
                height: 40,
              ),
              VerificationCode(
                textStyle: TextStyle(
                  fontSize: 40,
                ),
                underlineColor: Colors.black,
                length: 4,
                onCompleted: (String value) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      _code = value;
                    });
                  });
                },
                onEditing: (bool value) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      _code = "";
                      _onEditing = value;
                    });
                    if (!_onEditing) FocusScope.of(context).unfocus();
                  });
                },
              ),
              const Spacer(),
              SingleButtonWidget(
                content: '수정하기',
                onPressed: _code != "" ? () {
                  //TODO PIN 번호 수정
                } : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
