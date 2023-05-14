import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/map/search_route_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';
import 'package:majoong/model/response/map/search_route_response_dto.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';

import '../../service/remote/api/user/user_api_service.dart';

final searchRouteProvider =
StateNotifierProvider<SearchRouteStateNotifier, BaseResponseState>((ref) {
  final mapApi = ref.read(mapApiServiceProvider);
  final notifier = SearchRouteStateNotifier(mapApi: mapApi);
  return notifier;
});

class SearchRouteStateNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService mapApi;

  SearchRouteStateNotifier({required this.mapApi})
      : super(BaseResponseLoading());

  getRoute(double startLat, double startLng, double endLat, double endLng) async {
    final response =await mapApi.getRoute(SearchRouteRequestDto(
        startLng: startLng, startLat: startLat, endLng: endLng, endLat: endLat));
    if(response.status == 200){
      state = response;
      logger.d('경로 검색 성공, $state');
    }
  }

}
