import 'package:json_annotation/json_annotation.dart';

abstract class BaseResponseState {}

/** 데이터 로딩 중 */
class BaseResponseLoading extends BaseResponseState {}

/** 데이터 로딩 에러 */
class BaseResponseError extends BaseResponseState {
  final String message;

  BaseResponseError({required this.message});
}

/** 데이터 호출 완료 */
@JsonSerializable()
class BaseResponse<T> extends BaseResponseState {
  final String status;
  final String message;
  final T? data;

  BaseResponse(
      {required this.status, required this.message, required this.data});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse<T>(
        status: json['status'] as String,
        message: json['message'] as String,
        data: json['data']);
  }
}
