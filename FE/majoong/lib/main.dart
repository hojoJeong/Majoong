import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/view/splash_screen.dart';
import 'package:majoong/common/util/provider_logger.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: KAKAO_NATIVE_KEY
  );
  runApp(
    ProviderScope(
      observers: [
        ProviderLogger()
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    ),
  );
}
