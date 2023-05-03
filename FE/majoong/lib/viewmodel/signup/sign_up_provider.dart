import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/sign_up_request_dto.dart';
import 'package:majoong/service/remote/api/user_api_service.dart';

final signUpProvider = StateNotifierProvider<SignUpStateNotifier, bool>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = SignUpStateNotifier(userApi: userApi);

  return notifier;
});

class SignUpStateNotifier extends StateNotifier<bool> {
  final UserApiService userApi;

  SignUpStateNotifier({required this.userApi}) : super(false);

  signUp(SignUpRequestDto request) async {
    final response = await userApi.signUp(request);
    return response.status == 200 ? true : false;
  }
}
