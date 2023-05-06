import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';

import '../../model/request/user/edit_user_info_request_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';
import '../../service/remote/api/user/user_api_service.dart';

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, BaseResponseState>((ref) {
  final userService = ref.watch(userApiServiceProvider);
  final userInfoNotifier = UserInfoNotifier(service: userService);
  return userInfoNotifier;
});

class UserInfoNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService service;

  UserInfoNotifier({required this.service}) : super(BaseResponseLoading()) {
    getUserInfo();
  }

  getUserInfo() async {
    state = BaseResponseLoading();
    final BaseResponse<UserInfoResponseDto> response =
        await service.getUserInfo();
    if (response.status == 200) {
      state = response;
    } else {
      state = BaseResponseError(message: response.message);
    }
  }

  editUserInfo(EditUserInfoRequestDto request) async {
    final response = await service.editUserInfo(request);
    logger.d('edit user info : ${response.status}');
    state = response;
    if(response.status == 200){
      logger.d('회원정보 수정 성공');
    }
  }
}