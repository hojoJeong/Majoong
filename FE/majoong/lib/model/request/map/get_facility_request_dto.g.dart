// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_facility_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetFacilityRequestDto _$GetFacilityRequestDtoFromJson(
        Map<String, dynamic> json) =>
    GetFacilityRequestDto(
      centerLng: (json['centerLng'] as num).toDouble(),
      centerLat: (json['centerLat'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );

Map<String, dynamic> _$GetFacilityRequestDtoToJson(
        GetFacilityRequestDto instance) =>
    <String, dynamic>{
      'centerLng': instance.centerLng,
      'centerLat': instance.centerLat,
      'radius': instance.radius,
    };
