import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

import '../../common/const/key_value.dart';
import '../../service/local/secure_storage.dart';

final getGuardianListProvider =
    StateNotifierProvider<GetGuardiansStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = GetGuardiansStateNotifier(userApi: userApi, secureStorage: secureStorage);
  return notifier;
});

class GetGuardiansStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;
  int userId = 0;
  GetGuardiansStateNotifier({required this.userApi, required this.secureStorage})
      : super(BaseResponseLoading()) {
    getGuardianList();
  }

  getGuardianList() async {
    final response = await userApi.getFriendList(1);
    userId = int.parse((await secureStorage.read(key: USER_ID)).toString());
    if (response.status == 200) {
      state = response;
    }
  }
}
