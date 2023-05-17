import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/favorite/favorite_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final favoriteListStateProvider =
    StateNotifierProvider.autoDispose<FavoriteListStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = FavoriteListStateNotifier(userApi: userApi);
  return notifier;
});

class FavoriteListStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;

  FavoriteListStateNotifier({required this.userApi})
      : super(BaseResponseLoading()) {
    getFavoriteList();
  }

  getFavoriteList() async {
    final response = await userApi.getFavoriteList();
    state = response;
  }

  deleteFavorite(FavoriteRequestDto request) async {
    final response = await userApi.deleteFavorite(request);
    logger.d('즐겨찾기 삭제 완료 : ${response.status}, ${response.message}');
    getFavoriteList();
  }

  addFavorite(FavoriteRequestDto request) async {
    final response = await userApi.addFavorite(request);
    logger.d('즐겨찾기 추가 완료 : ${response.status}, ${response.message}');
    getFavoriteList();
  }
}
