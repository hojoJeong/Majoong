import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/firebase_options.dart';
import 'package:majoong/view/favorite/favorite_screen.dart';
import 'package:majoong/view/login/splash_screen.dart';
import 'package:majoong/common/util/provider_logger.dart';

/**
 * iOS 권한을 요청하는 함수
 */
Future reqIOSPermission(FirebaseMessaging fbMsg) async {
  NotificationSettings settings = await fbMsg.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KakaoSdk.init(nativeAppKey: KAKAO_NATIVE_KEY);
  GetStorage.init();
  final fcmMessaging = FirebaseMessaging.instance;
  String? token = await fcmMessaging.getToken(vapidKey: FCM_PUSH_KEY);
  logger.d('token : $token');

  //FCM 토큰은 사용자가 앱을 삭제, 재설치 및 데이터제거를 하게되면 기존의 토큰은 효력이 없고 새로운 토큰이 발금된다.
  fcmMessaging.onTokenRefresh.listen((nToken) {
    token = nToken;
    logger.d('fcm token refresh : $nToken');
  });

  // initFcm(fcmMessaging);

  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          fcmToken: token ?? '',
        ),
      ),
    ),
  );

}
