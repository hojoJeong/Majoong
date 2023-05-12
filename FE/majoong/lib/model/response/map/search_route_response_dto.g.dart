// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_route_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRouteResponseDto _$SearchRouteResponseDtoFromJson(
        Map<String, dynamic> json) =>
    SearchRouteResponseDto(
      shortestPath: RouteInfoResponseDto.fromJson(
          json['shortestPath'] as Map<String, dynamic>),
      recommendedPath: json['recommendedPath'] == null
          ? null
          : RouteInfoResponseDto.fromJson(
              json['recommendedPath'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchRouteResponseDtoToJson(
        SearchRouteResponseDto instance) =>
    <String, dynamic>{
      'shortestPath': instance.shortestPath,
      'recommendedPath': instance.recommendedPath,
    };
