import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/map/search_route_request_dto.dart';
import 'package:majoong/model/request/map/search_route_request_model.dart';
import 'package:majoong/model/response/base_response.dart';

final routePointProvider = StateNotifierProvider<
    RoutePointStateNotifier, SearchRoutePointRequestModel>((ref) {
  final notifier = RoutePointStateNotifier();
  return notifier;
});

class RoutePointStateNotifier
    extends StateNotifier<SearchRoutePointRequestModel> {
  RoutePointStateNotifier()
      : super(SearchRoutePointRequestModel(
            startLocationName: '',
            startLat: -1,
            startLng: -1,
            endLocationName: '',
            endLat: -1,
            endLng: -1));

  addStartPoint(String locationName, double lat, double lng) {
    state.startLocationName = locationName;
    state.startLat = lat;
    state.startLng = lng;
  }

  addEndPoint(String locationName, double lat, double lng) {
    state.endLocationName = locationName;
    state.endLat = lat;
    state.endLng = lng;
  }

  changePoint() {
    final temp = state;
    state = SearchRoutePointRequestModel(
        startLocationName: temp.endLocationName,
        startLat: temp.endLat,
        startLng: temp.endLng,
        endLocationName: temp.startLocationName,
        endLat: temp.endLat,
        endLng: temp.endLng);

    logger.d(
        'change point - start : ${state.startLocationName}, end : ${state.endLocationName}');
  }

  refreshState() {
    state = SearchRoutePointRequestModel(
        startLocationName: '',
        startLat: -1,
        startLng: -1,
        endLocationName: '',
        endLat: -1,
        endLng: -1);
  }
}
