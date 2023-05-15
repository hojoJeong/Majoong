import 'package:json_annotation/json_annotation.dart';

part 'get_review_response_dto.g.dart';

@JsonSerializable()
class GetReviewResponseDto {
  final int reviewId;
  final String address;
  final int score;
  final String content;
  final String? reviewImage;
  final bool bright;
  final bool crowded;

  factory GetReviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GetReviewResponseDtoFromJson(json);

  GetReviewResponseDto(this.reviewId, this.address, this.score, this.content,
      this.reviewImage, this.bright, this.crowded);
}
