import 'package:json_annotation/json_annotation.dart';

part 'verify_number_request_dto.g.dart';

@JsonSerializable()
class VerifyNumberRequestDto {
  final String phoneNumber;
  final String verificationNumber;

  VerifyNumberRequestDto(
      {required this.phoneNumber, required this.verificationNumber});

  factory VerifyNumberRequestDto.fronJson(Map<String, dynamic> json) => _$VerifyNumberRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyNumberRequestDtoToJson(this);
}
