// GENERATED CODE - DO NOT MODIFY BY HAND

part of 're_token_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReTokenResponseDto _$ReTokenResponseDtoFromJson(Map<String, dynamic> json) =>
    ReTokenResponseDto(
      userId: json['userId'] as int,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$ReTokenResponseDtoToJson(ReTokenResponseDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
