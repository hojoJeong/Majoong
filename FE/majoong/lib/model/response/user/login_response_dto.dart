import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';
@JsonSerializable()
class LoginResponseDto {
  final int userId;
  final String accessToken;
  final String refreshToken;
  final String phoneNumber;
  final String pinNumber;

  LoginResponseDto({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.phoneNumber,
    required this.pinNumber
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) => _$LoginResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}