
import 'package:json_annotation/json_annotation.dart';

part 'pin_number_response_dto.g.dart';

@JsonSerializable()
class PinNumberResponseDto {
  final String pinNumber;

  PinNumberResponseDto({required this.pinNumber});

  factory PinNumberResponseDto.fromJson(Map<String, dynamic> json) => _$PinNumberResponseDtoFromJson(json);
}