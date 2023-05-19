import 'package:json_annotation/json_annotation.dart';

part 'get_recordings_response_dto.g.dart';
@JsonSerializable()
class GetRecordingResponseDto{
  final String recordingId;
  final String thumbnailImageUrl;
  final String recordingUrl;
  final String createdAt;
  final int duration;
  GetRecordingResponseDto(this.recordingId, this.thumbnailImageUrl, this.recordingUrl, this.createdAt, this.duration);
  factory GetRecordingResponseDto.fromJson(Map<String, dynamic> json) => _$GetRecordingResponseDtoFromJson(json);

}