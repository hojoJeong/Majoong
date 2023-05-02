import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/view/login_screen.dart';

class DioInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  DioInterceptor({required this.secureStorage});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    logger.d('[REQ] [${options.method}]  ${options.uri}, ${options.data}');

    /** auth API 호출 시 */
    if (options.headers[AUTHORIZATION] == AUTH) {
      options.headers.remove(ACCESS_TOKEN);
      final token = await secureStorage.read(key: ACCESS_TOKEN);
      options.headers.addAll({ACCESS_TOKEN: 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('[RES] [$response]');
    super.onResponse(response, handler);
  }

  /** http 401 -> access token 만료, http 200 status 401 -> refresh 만료 */
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
    logger.d('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final response =
        BaseResponse.fromJson(err.response!.data as Map<String, dynamic>);
    final isRequestReToken = err.requestOptions.path == 'user/retoken';

    try {
      if (err.response!.statusCode == 401 && !isRequestReToken) {
        logger.d('accessToken 만료');

        final refreshToken = await secureStorage.read(key: REFRESH_TOKEN);
        if (refreshToken == null) {
          return handler.reject(err);
        }

        final dio = Dio();
        final reTokenResponse = await dio.post('${BASE_URL}user/retoken',
            options:
                Options(headers: {REFRESH_TOKEN: 'Bearer $refreshToken'}));
        final newAccessToken = BaseResponse.fromJson(reTokenResponse.data).data['accessToken'];

        logger.d('accessToken 재발급 : $newAccessToken');

        final options = err.requestOptions;
        options.headers.addAll({
          ACCESS_TOKEN: 'Bearer $newAccessToken',
        });

        await secureStorage.write(key: ACCESS_TOKEN, value: newAccessToken);

        final newResponse = await dio.fetch(options);
        return handler.resolve(newResponse);
      } else if (isRequestReToken && response.status == 401) {
        logger.d('refreshToken 만료, 로그인 페이지로 이동');
        Navigator.pushReplacement(err.requestOptions.extra['context'],
            MaterialPageRoute(builder: (contex) => LoginScreen()));
      }
    } catch (e) {
      return handler.reject(err);
    }
  }
}
