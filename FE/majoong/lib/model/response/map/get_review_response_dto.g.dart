// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_review_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetReviewResponseDto _$GetReviewResponseDtoFromJson(
        Map<String, dynamic> json) =>
    GetReviewResponseDto(
      json['reviewId'] as int,
      json['address'] as String,
      json['score'] as int,
      json['content'] as String,
      json['reviewImage'] as String,
      json['bright'] as bool,
      json['crowded'] as bool,
    );

Map<String, dynamic> _$GetReviewResponseDtoToJson(
        GetReviewResponseDto instance) =>
    <String, dynamic>{
      'reviewId': instance.reviewId,
      'address': instance.address,
      'score': instance.score,
      'content': instance.content,
      'reviewImage': instance.reviewImage,
      'bright': instance.bright,
      'crowded': instance.crowded,
    };
