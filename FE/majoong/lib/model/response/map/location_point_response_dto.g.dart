// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_point_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationPointResponseDto _$LocationPointResponseDtoFromJson(
        Map<String, dynamic> json) =>
    LocationPointResponseDto(
      lng: (json['lng'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationPointResponseDtoToJson(
        LocationPointResponseDto instance) =>
    <String, dynamic>{
      'lng': instance.lng,
      'lat': instance.lat,
    };
