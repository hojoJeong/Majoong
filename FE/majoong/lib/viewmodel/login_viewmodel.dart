import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user_api_service.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';

final userApiServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final userApiService = UserApiService(dio);
  return userApiService;
});

class LoginViewModel {

}

final loginProvider = Provider((ref) {
  final userApi = ref.watch(userApiServiceProvider);
});