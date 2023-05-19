import 'package:json_annotation/json_annotation.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';

part 'share_route_request_dto.g.dart';

@JsonSerializable()
class ShareRouteRequestDto {
  final int userId;
  final List<int> guardians;
  final RouteInfoResponseDto path;

  ShareRouteRequestDto(
      {required this.userId, required this.guardians, required this.path});

  Map<String, dynamic> toJson() => _$ShareRouteRequestDtoToJson(this);
}
