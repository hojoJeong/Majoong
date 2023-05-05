// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteResponseDto _$FavoriteResponseDtoFromJson(Map<String, dynamic> json) =>
    FavoriteResponseDto(
      favoriteId: json['favoriteId'] as int,
      locationName: json['locationName'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$FavoriteResponseDtoToJson(
        FavoriteResponseDto instance) =>
    <String, dynamic>{
      'favoriteId': instance.favoriteId,
      'locationName': instance.locationName,
      'address': instance.address,
    };
