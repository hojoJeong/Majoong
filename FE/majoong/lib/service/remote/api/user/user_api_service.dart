import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/login_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/model/response/user/re_token_response_dto.dart';
import 'package:majoong/model/response/user/user_info_response_dto.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

import '../../../../common/const/path.dart';
import '../../../../model/request/receive_number_request_dto.dart';
import '../../../../model/request/user/sign_up_request_dto.dart';
import '../../../../model/request/verify_number_request_dto.dart';

part 'user_api_service.g.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final userApiService = UserApiService(dio);
  return userApiService;
});

@RestApi(baseUrl: BASE_URL)
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/retoken')
  Future<BaseResponse<ReTokenResponseDto>> getNewAccessToken();

  @Headers({AUTHORIZATION: NO_AUTH})
  @POST('user/login')
  Future<BaseResponse<LoginResponseDto>> login(@Body() LoginRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/auto-login')
  Future<BaseResponse<LoginResponseDto>> autoLogin();

  @Headers({AUTHORIZATION: NO_AUTH})
  @POST('user/phone')
  Future<BaseResponse> receiveVerificationNumber(
      @Body() ReceiveNumberRequestDto request);

  @Headers({AUTHORIZATION: NO_AUTH})
  @POST('user/phone/verify')
  Future<BaseResponse> verifyNumber(@Body() VerifyNumberRequestDto request);

  @Headers({AUTHORIZATION: NO_AUTH})
  @POST('user/signup')
  Future<BaseResponse> signUp(@Body() SignUpRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @GET('user')
  Future<BaseResponse<UserInfoResponseDto>> getUserInfo();
}
