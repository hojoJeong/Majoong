import 'package:json_annotation/json_annotation.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';

part 'accept_share_route_response_dto.g.dart';
@JsonSerializable()
class AcceptShareRouteResponseDto {
  final RouteInfoResponseDto path;
  final String nickname;
  final String phoneNumber;

  AcceptShareRouteResponseDto(
      {required this.path, required this.nickname, required this.phoneNumber});

  factory AcceptShareRouteResponseDto.fromJson(Map<String, dynamic> json) => _$AcceptShareRouteResponseDtoFromJson(json);
}
