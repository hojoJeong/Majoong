import 'package:json_annotation/json_annotation.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';

part 'search_route_response_dto.g.dart';

@JsonSerializable()
class SearchRouteResponseDto {
  final RouteInfoResponseDto shortestPath;
  final RouteInfoResponseDto? recommendedPath;

  SearchRouteResponseDto(
      {required this.shortestPath, required this.recommendedPath});

  factory SearchRouteResponseDto.fromJson(Map<String, dynamic> json) => _$SearchRouteResponseDtoFromJson(json);
}
