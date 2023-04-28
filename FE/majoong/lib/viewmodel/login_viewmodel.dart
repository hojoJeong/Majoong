import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/service/local/secure_storage.dart';

final checkAutoLoginProvider = FutureProvider.autoDispose<bool>((ref) async {
  final autoLogin = await SecureStorage().checkAutoLogin();
  if (autoLogin) {
    return true;
  } else {
    /** 자동 로그인 불가, false return 후 splash_screen에서 로그인 페이지로 이동 */
    return false;
  }
});

final loginProvider = FutureProvider.autoDispose((ref) async {

});

