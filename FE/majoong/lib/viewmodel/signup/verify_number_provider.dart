import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/request/user/verify_number_request_dto.dart';
import '../../service/remote/api/user/user_api_service.dart';

final verifyNumberProvider =
    StateNotifierProvider.autoDispose<VerifyNumberStateNotifier, int>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = VerifyNumberStateNotifier(userApi: userApi);

  return notifier;
});

class VerifyNumberStateNotifier extends StateNotifier<int> {
  final UserApiService userApi;

  VerifyNumberStateNotifier({required this.userApi}) : super(-1);

  verifyNumber(VerifyNumberRequestDto request) async {
    final response = await userApi.verifyNumber(request);
    state = response.status;
  }
}
