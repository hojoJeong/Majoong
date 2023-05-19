import 'package:json_annotation/json_annotation.dart';
part 'start_video_response_dto.g.dart';
@JsonSerializable()
class StartVideoResponseDto{
  final String sessionId;
  final String connectionId;
  final String connectionToken;

  StartVideoResponseDto(this.sessionId, this.connectionId, this.connectionToken);
  factory StartVideoResponseDto.fromJson(Map<String, dynamic> json) => _$StartVideoResponseDtoFromJson(json);
}