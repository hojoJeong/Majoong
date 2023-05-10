import 'package:json_annotation/json_annotation.dart';

part 'location_point_response_dto.g.dart';

@JsonSerializable()
class LocationPointResponseDto {
  final double lng;
  final double lat;

  LocationPointResponseDto({required this.lng, required this.lat});

  factory LocationPointResponseDto.fromJson(Map<String, dynamic> json) => _$LocationPointResponseDtoFromJson(json);
}
