import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/receive_number_request_dto.dart';
import 'package:majoong/service/remote/api/user_api_service.dart';

final receiveVerificationNumberProvide = StateNotifierProvider<ReceiveVerificationNumberStateNotifier, bool>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = ReceiveVerificationNumberStateNotifier(userApi: userApi);

  return notifier;
});

class ReceiveVerificationNumberStateNotifier extends StateNotifier<bool> {
  final UserApiService userApi;

  ReceiveVerificationNumberStateNotifier({required this.userApi})
      : super(false);

  receiveVerificationNumber(String phoneNumber) async {
    final response = await userApi.receiveVerificationNumber(ReceiveNumberRequestDto(phoneNumber: phoneNumber));
    if(response.status == 200){
      state = true;
    }
  }
}
