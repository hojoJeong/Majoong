import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/service/local/secure_storage.dart';

final checkAutoLoginProvider = FutureProvider.autoDispose<bool>((ref) async {
  final autoLogin = await SecureStorage().checkAutoLogin();
  if(autoLogin){
    /** 자동 로그인 가능, 로그인 API 호출 */
    return true;
  } else {
    /** 자동 로그인 불가, false return 후 splash_screen에서 로그인 페이지로 이동 */
    return false;
  }
});