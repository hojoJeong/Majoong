// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_route_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRouteRequestDto _$SearchRouteRequestDtoFromJson(
        Map<String, dynamic> json) =>
    SearchRouteRequestDto(
      startLng: (json['startLng'] as num).toDouble(),
      startLat: (json['startLat'] as num).toDouble(),
      endLng: (json['endLng'] as num).toDouble(),
      endLat: (json['endLat'] as num).toDouble(),
    );

Map<String, dynamic> _$SearchRouteRequestDtoToJson(
        SearchRouteRequestDto instance) =>
    <String, dynamic>{
      'startLng': instance.startLng,
      'startLat': instance.startLat,
      'endLng': instance.endLng,
      'endLat': instance.endLat,
    };
