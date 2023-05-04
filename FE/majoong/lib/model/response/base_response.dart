import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

abstract class BaseResponseState {}

/// 데이터 로딩 중
class BaseResponseLoading extends BaseResponseState {}

/// 데이터 로딩 에러
class BaseResponseError extends BaseResponseState {
  final String message;

  BaseResponseError({required this.message});
}

/// 데이터 호출 완료
@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> extends BaseResponseState {
  final int status;
  final String message;
  final T? data;

  BaseResponse(
      {required this.status, required this.message, required this.data});

  factory BaseResponse.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BaseResponseFromJson(json, fromJsonT);
}
