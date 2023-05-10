import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/favorite/favorite_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/search_places_model.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final searchRoutePointProvider =
    StateNotifierProvider.autoDispose<SearchRoutePointStateNotifier, BaseResponseState>(
        (ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = SearchRoutePointStateNotifier(userApi: userApi);
  return notifier;
});

class SearchRoutePointStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;

  SearchRoutePointStateNotifier({required this.userApi}) : super(BaseResponseLoading());

  getResultSearch(String query) async {
    final googlePlace = GoogleMapsPlaces(apiKey: GOOGLE_PLACE_API_KEY);
    PlacesSearchResponse response =
        await googlePlace.searchByText(query, language: 'ko');
    logger.d(response.status); //ZERO_RESULTS / OK

    if (response.status == 'ZERO_RESULTS') {
      state = BaseResponse(status: 600, message: '검색 결과가 없습니다.', data: []);
    } else if (response.status == 'OK') {
      final result = response.results;
      List<SearchPlacesModel> list = [];
      final favoriteList = await userApi.getFavoriteList();
      List<String> listForCheckingFavorite =
          favoriteList.data?.map((e) => e.locationName).toList() ?? [];
      List<int> favoriteIdList =
          favoriteList.data?.map((e) => e.favoriteId).toList() ?? [];
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
        final favoriteId = listForCheckingFavorite.contains(result[i].name)
            ? favoriteIdList[listForCheckingFavorite.indexOf(result[i].name)]
            : -1;

        list.add(SearchPlacesModel(
            image: image,
            locationName: locationName,
            address: address,
            isFavorite: isFavorite,
            lat: lat,
            lng: lng,
            favoriteId: favoriteId));

        logger
            .d('검색 : $image, $locationName, $address, $lat, $lng, $isFavorite');
      }

      state = BaseResponse(status: 200, message: '', data: list);
    }
  }

  setFavoritePlace(String address, String locationName) async {
    final response = await userApi.addFavorite(
        FavoriteRequestDto(address: address, locationName: locationName));
    if (response.status == 200) {
      logger.d('즐겨찾기 등록 완료');
    } else {
      logger.d('즐겨찾기 등록 실패');
    }
  }

  deleteFavoritePlace(int favoriteId) async {
    final response = await userApi.deleteFavorite(favoriteId);
    if (response.status == 200) {
      logger.d('즐겨찾기 삭제 완료');
    } else {
      logger.d('즐겨찾기 삭제 실패');
    }
  }
}
