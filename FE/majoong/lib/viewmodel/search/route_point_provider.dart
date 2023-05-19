import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/map/search_route_request_dto.dart';
import 'package:majoong/model/request/map/search_route_request_model.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:http/http.dart' as http;

import '../../common/const/app_key.dart';

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

  addEndPoint(String locationName, double lat, double lng, double curLat, double curLng) async {
    if(state.startLocationName == ''){
      final curAddress = await getAddress(curLat, curLng);
      state.startLocationName = curAddress ?? "";
      state.startLat = curLat;
      state.startLng = curLng;
    }
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

  refreshStartPoint(){
    state.startLocationName = '';
    state.startLat = -1;
    state.startLng = -1;
  }

  refreshEndPoint(){
    state.endLocationName = '';
    state.endLat = -1;
    state.endLng = -1;
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

  Future<String?> getAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_MAP_KEY&language=ko';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final results = decodedJson['results'] as List<dynamic>;
      final formattedAddresses = results
          .map((result) => result['formatted_address'] as String)
          .toList();
      logger.d('현재 위치 : $formattedAddresses');
      return formattedAddresses[0].replaceAll('대한민국', '');
    } else {
      return null;
    }
  }
}


