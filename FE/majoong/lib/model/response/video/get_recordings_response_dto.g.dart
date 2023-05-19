// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_recordings_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRecordingResponseDto _$GetRecordingResponseDtoFromJson(
        Map<String, dynamic> json) =>
    GetRecordingResponseDto(
      json['recordingId'] as String,
      json['thumbnailImageUrl'] as String,
      json['recordingUrl'] as String,
      json['createdAt'] as String,
      json['duration'] as int,
    );

Map<String, dynamic> _$GetRecordingResponseDtoToJson(
        GetRecordingResponseDto instance) =>
    <String, dynamic>{
      'recordingId': instance.recordingId,
      'thumbnailImageUrl': instance.thumbnailImageUrl,
      'recordingUrl': instance.recordingUrl,
      'createdAt': instance.createdAt,
      'duration': instance.duration,
    };
