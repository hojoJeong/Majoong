import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user_api_service.dart';

final autoLoginProvider = StateNotifierProvider<AutoLoginStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.watch(userApiServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final notifier = AutoLoginStateNotifier(userApi: userApi, secureStorage: secureStorage);

  return notifier;
});

class AutoLoginStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;

  AutoLoginStateNotifier({required this.userApi, required this.secureStorage})
      : super(BaseResponseLoading()) {
    autoLogin();
  }

  autoLogin() async {
    state = await userApi.autoLogin();
    if (state is BaseResponse<LoginResponseDto>) {
      final response = state as BaseResponse<LoginResponseDto>;
      final userInfo = response.data!;

      secureStorage.write(key: AUTO_LOGIN, value: AUTO_LOGIN);
      secureStorage.write(key: USER_ID, value: userInfo.userId.toString());
      secureStorage.write(key: ACCESS_TOKEN, value: userInfo.accessToken);
      secureStorage.write(key: REFRESH_TOKEN, value: userInfo.refreshToken);
    }
  }
}
