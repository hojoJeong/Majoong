import 'package:json_annotation/json_annotation.dart';

part 'search_route_request_dto.g.dart';
@JsonSerializable()
class SearchRouteRequestDto {
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  SearchRouteRequestDto(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  Map<String, dynamic> toJson() => _$SearchRouteRequestDtoToJson(this);
}
