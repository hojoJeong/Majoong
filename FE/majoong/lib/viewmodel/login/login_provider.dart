import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/login_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';
import 'package:majoong/viewmodel/login/login_request_state_provider.dart';

final loginProvier =
    StateNotifierProvider<LoginStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.watch(userApiServiceProvider);
  final loginRequest = ref.watch(loginRequestStateProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  final notifier = LoginStateNotifier(
      userApi: userApi, request: loginRequest, secureStorage: secureStorage);
  return notifier;
});

class LoginStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final LoginRequestDto request;
  final FlutterSecureStorage secureStorage;

  LoginStateNotifier(
      {required this.userApi,
      required this.request,
      required this.secureStorage})
      : super(BaseResponseLoading()) {
    login(request);
  }

  login(LoginRequestDto request) async {
    if (request.socialPK != "-1") {
      state = await userApi.login(request);

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
}
