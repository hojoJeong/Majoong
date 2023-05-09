import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/search_places_model.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final searchProvider =
    StateNotifierProvider.autoDispose<SearchStateNotifier, BaseResponseState>(
        (ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = SearchStateNotifier(userApi: userApi);
  return notifier;
});

class SearchStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;

  SearchStateNotifier({required this.userApi}) : super(BaseResponseLoading());

  getResultSearch(String query) async {
    final googlePlace = GoogleMapsPlaces(apiKey: GOOGLE_PLACE_API_KEY);
    PlacesSearchResponse response =
        await googlePlace.searchByText(query, language: 'ko');
    logger.d(response.status); //ZERO_RESULTS / OK

    final favoriteList = await userApi.getFavoriteList();
    List<String> listForCheckingFavorite =
        favoriteList.data?.map((e) => e.locationName).toList() ?? [];

    if (response.status == 'ZERO_RESULTS') {
      state = BaseResponse(status: 600, message: '검색 결과가 없습니다.', data: []);
    } else if (response.status == 'OK') {
      final result = response.results;
      List<SearchPlacesModel> list = [];
      final size = result.length > 20 ? 20 : result.length;
      for (int i = 0; i < size; i++) {
        String photoReference = BASE_PROFILE_URL;
        if (result[i].photos.isNotEmpty) {
          photoReference = result[i].photos[0].photoReference;
        }
        final image = photoReference != BASE_PROFILE_URL
            ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$GOOGLE_PLACE_API_KEY'
            : BASE_PROFILE_URL;
        final locationName = result[i].name;
        final address = result[i].formattedAddress!;
        final lat = result[i].geometry!.location.lat;
        final lng = result[i].geometry!.location.lng;
        final isFavorite =
            listForCheckingFavorite.contains(result[i].name) ? true : false;

        list.add(SearchPlacesModel(
            image: image,
            locationName: locationName,
            address: address,
            isFavorite: isFavorite,
            lat: lat,
            lng: lng));

        logger
            .d('검색 : $image, $locationName, $address, $lat, $lng, $isFavorite');
      }

      state = BaseResponse(status: 200, message: '', data: list);
    }
  }
}
