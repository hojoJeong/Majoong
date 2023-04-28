import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/view/splash_screen.dart';
import 'package:majoong/viewmodel/Logger.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: KAKAO_NATIVE_KEY
  );
  runApp(
    ProviderScope(
      observers: [
        Logger()
      ],
      child: MaterialApp(
        home: SplashScreen(),
      ),
    ),
  );
}
