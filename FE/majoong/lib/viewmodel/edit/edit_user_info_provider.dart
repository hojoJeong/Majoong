import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/pin_number_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/pin_number_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';
import 'package:majoong/viewmodel/main/user_info_provider.dart';

import '../../common/util/logger.dart';
import '../../model/request/user/edit_user_info_request_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';

final editUserInfoProvider = StateNotifierProvider.autoDispose<EditUserInfoStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final userInfo = ref.read(userInfoProvider) as BaseResponse<UserInfoResponseDto>;
  final secureStorage = ref.read(secureStorageProvider);
  final notifier =
      EditUserInfoStateNotifier(userApi: userApi, secureStorage: secureStorage, userInfo: userInfo.data!);
  return notifier;
});

class EditUserInfoStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;
  final UserInfoResponseDto userInfo;
  EditUserInfoStateNotifier(
      {required this.userApi, required this.secureStorage, required this.userInfo})
      : super(BaseResponseLoading());

  updateState(EditUserInfoRequestDto request){
    state = BaseResponse(status: -1, message: "", data: request);
  }

  editUserInfo(EditUserInfoRequestDto request) async {
    final response = await userApi.editUserInfo(request);
    logger.d('edit user info : ${response.status}, ${response.data}');
    if (response.status == 200) {
      state = response;
      logger.d('회원정보 수정 성공');
    }
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
