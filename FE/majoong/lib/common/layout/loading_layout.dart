import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';

class LoadingLayout extends StatelessWidget {
  const LoadingLayout({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TRANS_50_POLICE_MARKER_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '잠시만 기다려주세요 :)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: BASE_TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
            ),
            LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white, size: 60)
          ],
        ),
      ),
    );
  }
}
