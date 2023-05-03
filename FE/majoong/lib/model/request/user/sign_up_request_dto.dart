import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request_dto.g.dart';

@JsonSerializable()
class SignUpRequestDto {
  final String nickname;
  final String phoneNumber;
  final String profileImage;
  final String pinNumber;
  final String socialPK;

  SignUpRequestDto(
      {required this.nickname,
      required this.phoneNumber,
      required this.profileImage,
      required this.pinNumber,
      required this.socialPK});

  factory SignUpRequestDto.fromJson(Map<String, dynamic> json) => _$SignUpRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SignUpRequestDtoToJson(this);
}
