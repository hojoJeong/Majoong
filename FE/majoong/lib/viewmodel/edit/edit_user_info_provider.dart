import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/pin_number_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/model/response/user/pin_number_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';
import 'package:majoong/service/remote/dio/dio_interceptor.dart';
import 'package:majoong/viewmodel/main/user_info_provider.dart';
import 'package:retrofit/http.dart';

import '../../common/util/logger.dart';
import '../../model/request/user/edit_user_info_request_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';

final editUserInfoProvider = StateNotifierProvider.autoDispose<
    EditUserInfoStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final userInfo =
      ref.read(userInfoProvider) as BaseResponse<UserInfoResponseDto>;
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = EditUserInfoStateNotifier(
      userApi: userApi, secureStorage: secureStorage, userInfo: userInfo.data!);
  return notifier;
});

class EditUserInfoStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;
  final UserInfoResponseDto userInfo;

  EditUserInfoStateNotifier(
      {required this.userApi,
      required this.secureStorage,
      required this.userInfo})
      : super(BaseResponseLoading());

  editUserInfo(EditUserInfoRequestDto request) async {
    final token = await secureStorage.read(key: ACCESS_TOKEN);
    final formData = FormData.fromMap({
      'nickname': request.nickname,
      'phoneNumber': request.phoneNumber,
      'profileImage': request.profileImage != null
          ? await MultipartFile.fromFile(request.profileImage!.path,
              filename: null)
          : null
    });

    final dio = Dio();
    dio.interceptors
        .add(DioInterceptor(secureStorage: secureStorage, dio: dio));
    dio.options.headers.addAll({"Authorization": 'Bearer $token'});
    final response =
        await dio.put('https://majoong4u.com/api/user/profile', data: formData);
    state = BaseResponse(
        status: response.data['status'],
        message: response.data['message'],
        data: response.data['data']);
    logger.d(state);
  }

  editPinNumber(String pinNumber) async {
    final response =
        await userApi.editPinNumber(PinNumberRequestDto(pinNumber: pinNumber));
    logger.d('edit user info : ${response.status}, ${response.data}');
    if (response.status == 200 && response.data is PinNumberResponseDto) {
      state = response;
      secureStorage.write(key: PIN_NUM, value: response.data!.pinNumber);
      logger.d('Pin 번호 수정 성공');
    }
  }
}
