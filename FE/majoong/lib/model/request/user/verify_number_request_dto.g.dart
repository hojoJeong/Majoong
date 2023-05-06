// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_number_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyNumberRequestDto _$VerifyNumberRequestDtoFromJson(
        Map<String, dynamic> json) =>
    VerifyNumberRequestDto(
      phoneNumber: json['phoneNumber'] as String,
      verificationNumber: json['verificationNumber'] as String,
    );

Map<String, dynamic> _$VerifyNumberRequestDtoToJson(
        VerifyNumberRequestDto instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'verificationNumber': instance.verificationNumber,
    };
