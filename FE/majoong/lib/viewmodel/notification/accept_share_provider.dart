import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

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
    }
  }
}