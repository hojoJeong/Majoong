// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_video_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartVideoResponseDto _$StartVideoResponseDtoFromJson(
        Map<String, dynamic> json) =>
    StartVideoResponseDto(
      json['sessionId'] as String,
      json['connectionId'] as String,
      json['connectionToken'] as String,
    );

Map<String, dynamic> _$StartVideoResponseDtoToJson(
        StartVideoResponseDto instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'connectionId': instance.connectionId,
      'connectionToken': instance.connectionToken,
    };
