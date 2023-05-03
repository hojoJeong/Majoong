import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';

class DioInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

  DioInterceptor({required this.secureStorage, required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    logger.d('[REQ] [${options.method}] ${options.uri}');

    /** auth API 호출 시 */
    if (options.headers[AUTHORIZATION] == AUTH) {
      options.headers.remove(ACCESS_TOKEN);
      final token = await secureStorage.read(key: ACCESS_TOKEN);
      options.headers.addAll({
        "Authorization":
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MiwiaWF0IjoxNjgyOTEzOTIwLCJleHAiOjE2ODM1MTg3MjB9.FKf7FXHLz0BLzBQ_0XF6rxiwhDneM22aGXnpbN44P54'
      });
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    logger.d('[RES] [$response]');
  }

  /** http 401 -> access token 만료, http 200 status 401 -> refresh 만료 */
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    secureStorage.deleteAll();
    logger
        .d('[ERROR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    final refreshTorken = await secureStorage.read(key: REFRESH_TOKEN);
    if (refreshTorken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/user/retoken';

    if (isStatus401 && !isPathRefresh) {
      try {
        final resp = await dio.post('${BASE_URL}user/retoken',
            options:
                Options(headers: {'Authorization': 'Bearer $refreshTorken'}));
        final accessToken = resp.data['data']['accessToken'];
        logger.d(accessToken);

        final options = err.requestOptions;
        options.headers.addAll({'Authorization': 'Bearer $accessToken'});
        await secureStorage.write(key: ACCESS_TOKEN, value: accessToken);
        final newToken = await secureStorage.read(key: ACCESS_TOKEN);
        logger.d(newToken);
        // 원래 요청 재전송
        final response = await dio.fetch(options);
        logger.d(response.statusCode);
        return handler.resolve(response);
      } on DioError catch (e) {
        return handler.reject(e);
      }
    }
  }
}
