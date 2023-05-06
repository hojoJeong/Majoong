import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final favoriteListStateProvider =
    StateNotifierProvider<FavoriteListStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = FavoriteListStateNotifier(userApi: userApi);
  return notifier;
});

class FavoriteListStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;

  FavoriteListStateNotifier({required this.userApi})
      : super(BaseResponseLoading()){
    getFavoriteList();
  }

  getFavoriteList() async {
    final response = await userApi.getFavoriteList();
    state = response;
  }

  deleteFavorite(int favoriteId) async {
    final response = await userApi.deleteFavorite(favoriteId);
    logger.d('즐겨찾기 삭제 완료');
    state = response;
  }
}
