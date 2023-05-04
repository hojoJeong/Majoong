import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/receive_number_request_dto.dart';

import '../../service/remote/api/user/user_api_service.dart';

final receiveVerificationNumberProvide =
    StateNotifierProvider<ReceiveVerificationNumberStateNotifier, int>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = ReceiveVerificationNumberStateNotifier(userApi: userApi);

  return notifier;
});

class ReceiveVerificationNumberStateNotifier extends StateNotifier<int> {
  final UserApiService userApi;

  ReceiveVerificationNumberStateNotifier({required this.userApi}) : super(-1);

  receiveVerificationNumber(String phoneNumber) async {
    final response = await userApi.receiveVerificationNumber(
        ReceiveNumberRequestDto(phoneNumber: phoneNumber));
    state = response.status;
  }
}
