import 'package:json_annotation/json_annotation.dart';

part 'edit_user_info_response_dto.g.dart';

@JsonSerializable()
class EditUserInfoResponseDto {
  final String nickname;
  final String phoneNumber;
  final String profileImage;

  EditUserInfoResponseDto(
      {required this.nickname,
      required this.phoneNumber,
      required this.profileImage});


  factory EditUserInfoResponseDto.fromJson(Map<String, dynamic> json) => _$EditUserInfoResponseDtoFromJson(json);
}