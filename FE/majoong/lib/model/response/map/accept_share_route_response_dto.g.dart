// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_share_route_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptShareRouteResponseDto _$AcceptShareRouteResponseDtoFromJson(
        Map<String, dynamic> json) =>
    AcceptShareRouteResponseDto(
      path: RouteInfoResponseDto.fromJson(json['path'] as Map<String, dynamic>),
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$AcceptShareRouteResponseDtoToJson(
        AcceptShareRouteResponseDto instance) =>
    <String, dynamic>{
      'path': instance.path,
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
    };
