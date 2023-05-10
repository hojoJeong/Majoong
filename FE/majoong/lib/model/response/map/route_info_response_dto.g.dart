// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_info_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteInfoResponseDto _$RouteInfoResponseDtoFromJson(
        Map<String, dynamic> json) =>
    RouteInfoResponseDto(
      distance: json['distance'] as int,
      time: json['time'] as int,
      point: (json['point'] as List<dynamic>)
          .map((e) =>
              LocationPointResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteInfoResponseDtoToJson(
        RouteInfoResponseDto instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'time': instance.time,
      'point': instance.point,
    };
