import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';

class PinNumberScreen extends ConsumerStatefulWidget {
  const PinNumberScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PinNumberScreenState();
}

class PinNumberScreenState extends ConsumerState {
  bool _onEditing = true;
  String? _code = "";

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: 'PIN 번호 입력',
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: BASE_PADDING),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '경찰 신고 취소 등\n오작동 방지용으로 사용됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: BASE_TITLE_FONT_SIZE, color: Colors.black),
                ),
                SizedBox(
                  height: 40,
                ),
                VerificationCode(
                  textStyle: TextStyle(
                    fontSize: 40,
                  ),
                  underlineColor: Colors.black,
                  length: 4,
                  onCompleted: (String value) {
                    setState(() {
                      _code = value;
                    });
                  },
                  onEditing: (bool value) {
                    setState(() {
                      _code = "";
                      _onEditing = value;
                    });
                    if (!_onEditing) FocusScope.of(context).unfocus();
                  },
                ),
                Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: POLICE_MARKER_COLOR,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: _code != "" ? () {

                      } : null,
                      child: Text(
                        '가입하기',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: BASE_TITLE_FONT_SIZE),
                      )),
                )
              ],
            ),
          ),
        ),
        actions: []);
  }
}
