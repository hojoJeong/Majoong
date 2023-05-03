import 'package:json_annotation/json_annotation.dart';

part 'get_facility_request_dto.g.dart';

@JsonSerializable()
class GetFacilityRequestDto {
  final double centerLng;
  final double centerLat;
  final double radius;

  GetFacilityRequestDto(
      {required this.centerLng, required this.centerLat, required this.radius});

  Map<String, dynamic> toJson() => _$GetFacilityRequestDtoToJson(this);

  factory GetFacilityRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GetFacilityRequestDtoFromJson(json);
}
