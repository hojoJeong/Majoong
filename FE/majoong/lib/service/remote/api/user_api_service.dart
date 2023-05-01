import 'package:dio/dio.dart' hide Headers;
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/model/response/user/re_token_response_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

part 'user_api_service.g.dart';

@RestApi(baseUrl: "BASE_URL")
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  @Headers({REFRESH_TOKEN: AUTH})
  @GET('user/retoken')
  Future<BaseResponse<ReTokenResponseDto>> getNewAccessToken();

  @Headers({ACCESS_TOKEN: AUTH})
  @GET('user/auto-login')
  Future<BaseResponse<LoginResponseDto>> autoLogin();
}