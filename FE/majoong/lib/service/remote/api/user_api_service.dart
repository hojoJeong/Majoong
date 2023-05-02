import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/login_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/model/response/user/re_token_response_dto.dart';
import 'package:majoong/model/response/user/user_info_response_dto.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

import '../../../common/const/path.dart';

part 'user_api_service.g.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final userApiService = UserApiService(dio);
  return userApiService;
});
final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, UserInfoResponseDto>((ref) {
  final userService = ref.watch(userApiServiceProvider);
  final userInfoNotifier = UserInfoNotifier(service: userService);
  userInfoNotifier.getUserInfo();
  return userInfoNotifier;
});

class UserInfoNotifier extends StateNotifier<UserInfoResponseDto> {
  final UserApiService service;

  UserInfoNotifier({required this.service})
      : super(UserInfoResponseDto(
            userId: 0,
            phoneNumber: "phoneNumber",
            nickname: "nickname",
            profileImage: "profileImage",
            alarmCount: 1)) {
    getUserInfo();
  }

  UserInfoResponseDto getUserInfo() {
    service.getUserInfo().then((value) {
      if (value.data != null) {
        state = value.data!;
      }
    });
    return state;
  }
}

@RestApi(baseUrl: BASE_URL)
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  @Headers({REFRESH_TOKEN: AUTH})
  @GET('user/retoken')
  Future<BaseResponse<ReTokenResponseDto>> getNewAccessToken();

  @Headers({ACCESS_TOKEN: NO_AUTH})
  @POST('user/login')
  Future<BaseResponse<LoginResponseDto>> login(@Body() LoginRequestDto request);

  @Headers({ACCESS_TOKEN: AUTH})
  @POST('user/auto-login')
  Future<BaseResponse<LoginResponseDto>> autoLogin();

  @Headers({ACCESS_TOKEN: AUTH})
  @GET('user')
  Future<BaseResponse<UserInfoResponseDto>> getUserInfo();
}
