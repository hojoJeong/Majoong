import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';

final acceptShareProvider = StateNotifierProvider<AcceptShareStateNotifier, BaseResponseState>((ref) {
  final mapApi = ref.read(mapApiServiceProvider);
  final notifier = AcceptShareStateNotifier(mapApi: mapApi);
  return notifier;
});

class AcceptShareStateNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService mapApi;

  AcceptShareStateNotifier({required this.mapApi}): super(BaseResponseLoading());

  acceptShare(int userId) async {
    final response = await mapApi.acceptShareRoute(userId);
    if(response.status == 200){
      state = response;
    } else if(response.status == 404){
      state = response;
      logger.d('유효하지 않는 마중 요청입니다.');
      state = BaseResponseLoading();
    }
  }
}