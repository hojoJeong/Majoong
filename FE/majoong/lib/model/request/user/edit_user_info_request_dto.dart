import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/http.dart';

part 'edit_user_info_request_dto.g.dart';

@JsonSerializable()
class EditUserInfoRequestDto {
  final String nickname;
  final String phoneNumber;
  @JsonKey(name: 'profileImage', fromJson: _fileFromJson, toJson: _fileToJson)
  final File? profileImage;

  EditUserInfoRequestDto({
    required this.nickname,
    required this.phoneNumber,
    required this.profileImage,
  });

  factory EditUserInfoRequestDto.fromJson(Map<String, dynamic> json) =>
      _$EditUserInfoRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditUserInfoRequestDtoToJson(this);

  static File? _fileFromJson(String filePath) => File(filePath);

  static String? _fileToJson(File? file) => file?.path;
}