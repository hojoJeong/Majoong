import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';

final searchProvider = StateNotifierProvider<SearchStateNotifier, BaseResponseState>((ref) {
  final notifier = SearchStateNotifier();
  return notifier;
});

class SearchStateNotifier extends StateNotifier<BaseResponseState> {
  SearchStateNotifier(): super(BaseResponseLoading());

  getResultSearch(String query) async {
    final googlePlace = GoogleMapsPlaces(apiKey: GOOGLE_PLACE_API_KEY);
    PlacesSearchResponse response = await googlePlace.searchByText(query, language: 'ko');
    final result = response.results;
    final photoReference = response.results[0].photos[0].photoReference;
    final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$GOOGLE_PLACE_API_KEY';
    logger.d('${response.status}, ${response.results[0].name}, $photoUrl, ${response.results[0].formattedAddress}');
    state = BaseResponse(status: 200, message: '', data: '');
  }
}