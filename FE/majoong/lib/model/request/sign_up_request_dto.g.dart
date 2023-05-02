// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpRequestDto _$SignUpRequestDtoFromJson(Map<String, dynamic> json) =>
    SignUpRequestDto(
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImage: json['profileImage'] as String,
      pinNumber: json['pinNumber'] as String,
      socialPK: json['socialPK'] as String,
    );

Map<String, dynamic> _$SignUpRequestDtoToJson(SignUpRequestDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
      'profileImage': instance.profileImage,
      'pinNumber': instance.pinNumber,
      'socialPK': instance.socialPK,
    };
