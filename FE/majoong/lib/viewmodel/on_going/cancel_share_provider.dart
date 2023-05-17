import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final cancelShareProvider = StateNotifierProvider.autoDispose<CancelShareStateNotifier, BaseResponseState>((ref) {
  final mapApi = ref.read(mapApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = CancelShareStateNotifier(mapApi: mapApi, secureStorage: secureStorage);
  return notifier;
});

class CancelShareStateNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService mapApi;
  final FlutterSecureStorage secureStorage;
  CancelShareStateNotifier({required this.mapApi, required this.secureStorage}) : super(BaseResponseLoading());

  cancelShare() async {
    final userId = await secureStorage.read(key: USER_ID);
    final response = await mapApi.cancelShare(int.parse(userId ?? ""));
    if(response.status == 200){
      state = BaseResponse(status: 200, message: '공유 종료', data: null);
      logger.d('공유 종료 완료');
    }
  }
}