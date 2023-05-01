import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/dio/dio_interceptor.dart';

final dioProvider = Provider((ref) {
  final dio = Dio();
  final secureStorage = ref.watch(secureStorageProvider);
  dio.interceptors.add(DioInterceptor(secureStorage: secureStorage));

  return dio;
});