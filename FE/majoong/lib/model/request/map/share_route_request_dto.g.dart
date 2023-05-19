// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_route_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareRouteRequestDto _$ShareRouteRequestDtoFromJson(
        Map<String, dynamic> json) =>
    ShareRouteRequestDto(
      userId: json['userId'] as int,
      guardians:
          (json['guardians'] as List<dynamic>).map((e) => e as int).toList(),
      path: RouteInfoResponseDto.fromJson(json['path'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShareRouteRequestDtoToJson(
        ShareRouteRequestDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'guardians': instance.guardians,
      'path': instance.path,
    };
