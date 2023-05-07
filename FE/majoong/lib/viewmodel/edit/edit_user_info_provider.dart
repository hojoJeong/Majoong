import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/pin_number_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/pin_number_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

import '../../common/util/logger.dart';
import '../../model/request/user/edit_user_info_request_dto.dart';

final editUserInfoProvider = StateNotifierProvider.autoDispose((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier =
      EditUserInfoStateNotifier(userApi: userApi, secureStorage: secureStorage);
  return notifier;
});

class EditUserInfoStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;

  EditUserInfoStateNotifier(
      {required this.userApi, required this.secureStorage})
      : super(BaseResponseLoading());

  editUserInfo(EditUserInfoRequestDto request) async {
    final response = await userApi.editUserInfo(request);
    logger.d('edit user info : ${response.status}');
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
