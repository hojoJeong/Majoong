import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/favorite/favorite_request_dto.dart';
import 'package:majoong/model/request/user/edit_user_info_request_dto.dart';
import 'package:majoong/model/request/user/friend_request_request_dto.dart';
import 'package:majoong/model/request/user/login_request_dto.dart';
import 'package:majoong/model/request/user/pin_number_request_dto.dart';
import 'package:majoong/model/request/user/search_friend_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/favorite/favorite_response_dto.dart';
import 'package:majoong/model/response/user/edit_user_info_response_dto.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/model/response/user/notification_response_dto.dart';
import 'package:majoong/model/response/user/pin_number_response_dto.dart';
import 'package:majoong/model/response/user/re_token_response_dto.dart';
import 'package:majoong/model/response/user/user_info_response_dto.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

import '../../../../common/const/path.dart';
import '../../../../model/request/user/ReportRequestDto.dart';
import '../../../../model/request/user/delete_notification_request_dto.dart';
import '../../../../model/request/user/receive_number_request_dto.dart';
import '../../../../model/request/user/sign_up_request_dto.dart';
import '../../../../model/request/user/verify_number_request_dto.dart';

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

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/favorite')
  Future<BaseResponse<List<FavoriteResponseDto>>> getFavoriteList();

  @Headers({AUTHORIZATION: AUTH})
  @DELETE('user/favorite/{favoriteId}')
  Future<BaseResponse<bool>> deleteFavorite(@Path('favoriteId') int favoriteId);

  @Headers({AUTHORIZATION: AUTH})
  @PUT('user/profile')
  Future<BaseResponse<EditUserInfoResponseDto>> editUserInfo(
      @Field() String nickname,
      @Field() String phoneNumber,
      @Part() MultipartFile? profileImage);

  @Headers({AUTHORIZATION: AUTH})
  @PUT('user/pin')
  Future<BaseResponse<PinNumberResponseDto>> editPinNumber(
      @Body() PinNumberRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/friendrequests')
  Future<BaseResponse<List<FriendResponseDto>>> getFriendRequestList();

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/friends/{isGuardian}')
  Future<BaseResponse<List<FriendResponseDto>>> getFriendList(
      @Path('isGuardian') int isGuardian);

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/search')
  Future<BaseResponse<FriendResponseDto>> searchFriend(
      @Body() SearchFriendRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/friend')
  Future<BaseResponse> requestFriend(@Body() FriendRequestRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/friend/accept')
  Future<BaseResponse> acceptFriendRequest(
      @Body() FriendRequestRequestDto request);

  /// response 상의 필요

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/friend/deny')
  Future<BaseResponse> denyFriendRequest(
      @Body() FriendRequestRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @PUT('user/guardian')
  Future<BaseResponse> editGuardian(@Body() FriendRequestRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @DELETE('user/friend')
  Future<BaseResponse> deleteFriend(@Body() FriendRequestRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/phone112')
  Future<BaseResponse> sendPhone112(@Body() ReportRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @GET('user/notification')
  Future<BaseResponse<List<NotificationResponseDto>>> getNotificationList();

  @Headers({AUTHORIZATION: AUTH})
  @DELETE('user/notification')
  Future<BaseResponse> deleteNotification(@Body() DeleteNotificationRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('user/favorite')
  Future<BaseResponse> addFavorite(@Body() FavoriteRequestDto request);
}
