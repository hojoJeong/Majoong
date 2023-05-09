import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/viewmodel/login/fcm_token_provider.dart';

import '../../common/const/app_key.dart';
import '../../model/request/user/login_request_dto.dart';
import '../../service/remote/api/user/user_api_service.dart';
import 'login_request_state_provider.dart';

final loginProvider =
    StateNotifierProvider<LoginStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final loginRequest = ref.read(loginRequestStateProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final fcmToken = ref.read(fcmTokenProvider);
  final notifier = LoginStateNotifier(
      userApi: userApi, request: loginRequest, secureStorage: secureStorage, fcmToken: fcmToken);

  return notifier;
});

class LoginStateNotifier extends StateNotifier<BaseResponseState> {

  final UserApiService userApi;
  final LoginRequestDto request;
  final FlutterSecureStorage secureStorage;
  final String fcmToken;

  LoginStateNotifier(
      {required this.userApi,
      required this.request,
      required this.secureStorage,
      required this.fcmToken})
      : super(BaseResponseLoading());

  setStateBaseResponseLoading() {
    state = BaseResponseLoading();
  }

  login(LoginRequestDto? request) async {
    final isAutoLogin =
        await secureStorage.read(key: AUTO_LOGIN) == AUTO_LOGIN ? true : false;
    late BaseResponse response;
    logger.d('isAutoLogin : $isAutoLogin');

    if (isAutoLogin && state is BaseResponseLoading) {
      response = await userApi.autoLogin();
      state = response;
      logger.d(
          "login provider response auto: ${response.status}, ${response.message}, ${response.data}");
    } else {
      if (request!.socialPK != "-1" && state is BaseResponseLoading) {
        response = await userApi.login(request);
        state = response;
        logger.d(
            "login provider response : ${response.status}, ${response.message}, ${response.data}");
      }
    }

    if (response.data != null) {
      final response = state as BaseResponse<LoginResponseDto>;
      final userInfo = response.data!;

      await secureStorage.write(key: AUTO_LOGIN, value: AUTO_LOGIN);
      await secureStorage.write(
          key: USER_ID, value: userInfo.userId.toString());
      await secureStorage.write(key: ACCESS_TOKEN, value: userInfo.accessToken);
      await secureStorage.write(
          key: REFRESH_TOKEN, value: userInfo.refreshToken);
      await secureStorage.write(key: PIN_NUM, value: userInfo.pinNumber);
      final token = await secureStorage.read(key: ACCESS_TOKEN);
      print('Save AUTO_LOGIN into SecureStorage : $token');
    }
  }
}
