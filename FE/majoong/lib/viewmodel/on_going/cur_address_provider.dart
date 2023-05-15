import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/const/app_key.dart';
import 'package:http/http.dart' as http;

import '../../common/util/logger.dart';

final curAddressProvider = StateNotifierProvider<CurAddressStateNotifier, String>((ref) {
  final notifier = CurAddressStateNotifier();
  return notifier;
});

class CurAddressStateNotifier extends StateNotifier<String> {
  CurAddressStateNotifier() : super("");
  String address = "";

  Future<String?> getAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_MAP_KEY&language=ko';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final results = decodedJson['results'] as List<dynamic>;
      final formattedAddresses = results
          .map((result) => result['formatted_address'] as String)
          .toList();
      logger.d('현재 좌표 : $lat, $lng');
      logger.d('현재 위치 : $formattedAddresses');
      return formattedAddresses[0].replaceAll('대한민국', '');
    } else {
      return null;
    }
  }
}
