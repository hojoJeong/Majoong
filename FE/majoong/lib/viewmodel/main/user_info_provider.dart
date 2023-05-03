import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/response/user/user_info_response_dto.dart';
import '../../service/remote/api/user/user_api_service.dart';

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, UserInfoResponseDto>((ref) {
  final userService = ref.watch(userApiServiceProvider);
  final userInfoNotifier = UserInfoNotifier(service: userService);
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

  getUserInfo() {
    service.getUserInfo().then((value) {
      if (value.data != null) {
        state = value.data!;
      }
    });
  }
}
