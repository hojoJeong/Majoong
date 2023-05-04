import 'package:json_annotation/json_annotation.dart';

part 're_token_response_dto.g.dart';
@JsonSerializable()
class ReTokenResponseDto {
  final int userId;
  final String accessToken;
  final String refreshToken;

  ReTokenResponseDto(
      {required this.userId,
      required this.accessToken,
      required this.refreshToken});

  factory ReTokenResponseDto.fromJson(Map<String, dynamic> json) => _$ReTokenResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ReTokenResponseDtoToJson(this);
}
