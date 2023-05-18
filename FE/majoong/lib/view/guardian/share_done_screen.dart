import 'package:flutter/material.dart';
import 'package:majoong/common/component/signle_button_widget.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/view/main/main_screen.dart';

class ShareDoneScreen extends StatelessWidget {
  const ShareDoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(title: '공유 종료', body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WillPopScope(child: Container(), onWillPop: () async {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
          return true;
        }),
        Text('공유가 종료되었습니다.'),
        Spacer(),
        SingleButtonWidget(content: '메인으로 이동', onPressed: (){
          logger.d('버튼 클릭');
          Navigator.pop(context);
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
        })
      ],
    ));
  }
}
