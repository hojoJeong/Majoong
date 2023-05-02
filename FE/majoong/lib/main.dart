import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/view/main_screen.dart';
import 'package:majoong/view/splash_screen.dart';
import 'package:majoong/common/util/provider_logger.dart';

import 'common/const/app_key.dart';

void main() {
  KakaoSdk.init(nativeAppKey: KAKAO_NATIVE_KEY);
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    ),
  );
}
