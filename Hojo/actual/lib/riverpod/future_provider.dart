import 'package:flutter_riverpod/flutter_riverpod.dart';

final multipleFutureProvider = FutureProvider<List<int>>((ref) async {
  await Future.delayed(Duration(seconds: 2));

  throw Exception('error!!');
  return[1,2,3,4,5];
});