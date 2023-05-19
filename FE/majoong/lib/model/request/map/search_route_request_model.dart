import 'package:majoong/model/request/map/search_route_request_dto.dart';

class SearchRoutePointRequestModel {
  String startLocationName;
  double startLat;
  double startLng;
  String endLocationName;
  double endLat;
  double endLng;

  SearchRoutePointRequestModel(
      {required this.startLocationName,
      required this.startLat,
      required this.startLng,
      required this.endLocationName,
      required this.endLat,
      required this.endLng});
}
