import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/login_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/viewmodel/login/login_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.read(loginProvier) as BaseResponse;
    logger.d(status.data);
    return DefaultLayout(title: '', body: Container(
      child: Text('home')
    ), actions: []);
  }
}
