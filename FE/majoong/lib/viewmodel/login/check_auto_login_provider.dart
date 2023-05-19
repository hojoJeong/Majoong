import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/service/local/secure_storage.dart';

final checkAutoLoginProvider =
    StateNotifierProvider<CheckAutoLoginStateNotifier, int>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = CheckAutoLoginStateNotifier(secureStorage: secureStorage);

  return notifier;
});

class CheckAutoLoginStateNotifier extends StateNotifier<int> {
  final FlutterSecureStorage secureStorage;

  CheckAutoLoginStateNotifier({required this.secureStorage}) : super(-1) {
    checkAutoLogin();
  }

  checkAutoLogin() async {
    final response = await secureStorage.read(key: AUTO_LOGIN);
    state = response == AUTO_LOGIN ? 1 : 0;
  }
}
