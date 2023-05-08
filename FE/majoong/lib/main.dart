import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:logger/logger.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/firebase_options.dart';
import 'package:majoong/view/login/login_screen.dart';
import 'package:majoong/view/login/splash_screen.dart';
import 'package:majoong/common/util/provider_logger.dart';

void main() {
  KakaoSdk.init(nativeAppKey: KAKAO_NATIVE_KEY);
  GetStorage.init();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}
