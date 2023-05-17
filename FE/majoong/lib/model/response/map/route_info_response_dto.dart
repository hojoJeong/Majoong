import 'package:json_annotation/json_annotation.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';

part 'route_info_response_dto.g.dart';
@JsonSerializable()
class RouteInfoResponseDto {
  final int distance;
  final int time;
  final List<LocationPointResponseDto> point;

  RouteInfoResponseDto(
      {required this.distance, required this.time, required this.point});

  factory RouteInfoResponseDto.fromJson(Map<String, dynamic> json) => _$RouteInfoResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RouteInfoResponseDtoToJson(this);
}
