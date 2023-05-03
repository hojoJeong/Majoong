import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/verify_number_request_dto.dart';
import 'package:majoong/service/remote/api/user_api_service.dart';

final verifyNumberProvider = StateNotifierProvider<VerifyNumberStateNotifier, bool>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = VerifyNumberStateNotifier(userApi: userApi);

  return notifier;
});

class VerifyNumberStateNotifier extends StateNotifier<bool>{
  final UserApiService userApi;

  VerifyNumberStateNotifier({
    required this.userApi
}): super(false);

  verifyNumber(VerifyNumberRequestDto request) async {
    final response = await userApi.verifyNumber(request);
    state = response.status == 200 ? true : false;
  }
}