import 'package:json_annotation/json_annotation.dart';

part 'ReportRequestDto.g.dart';

@JsonSerializable()
class ReportRequestDto {
  final String content;

  ReportRequestDto(this.content);

  factory ReportRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportRequestDtoToJson(this);
}
