import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final storage = const FlutterSecureStorage();

  Future<bool> checkAutoLogin() async => await storage.read(key: 'autoLogin') != null ? true : false;
}