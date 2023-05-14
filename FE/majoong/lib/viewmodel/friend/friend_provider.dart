import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/user/friend_request_request_dto.dart';
import 'package:majoong/model/request/user/search_friend_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_list_model.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

import '../../common/util/logger.dart';

final friendProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = FriendStateNotifier(
      userApi: userApi, secureStorage: secureStorage, isController: true);
  return notifier;
});

final searchFriendProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = FriendStateNotifier(
      userApi: userApi, secureStorage: secureStorage, isController: false);
  return notifier;
});

final requestFriendProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
      final userApi = ref.read(userApiServiceProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final notifier = FriendStateNotifier(
          userApi: userApi, secureStorage: secureStorage, isController: false);
      return notifier;
    });

final friendRequestListProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = FriendStateNotifier(
      userApi: userApi, secureStorage: secureStorage, isController: false);
  return notifier;
});

final friendListProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = FriendStateNotifier(
      userApi: userApi, secureStorage: secureStorage, isController: false);
  return notifier;
});

final guardianListProvider =
    StateNotifierProvider<FriendStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = FriendStateNotifier(
      userApi: userApi, secureStorage: secureStorage, isController: false);
  return notifier;
});

class FriendStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;
  final FlutterSecureStorage secureStorage;
  final bool isController;

  FriendStateNotifier(
      {required this.userApi,
      required this.secureStorage,
      required this.isController})
      : super(BaseResponseLoading()) {
    if (isController) {
      refreshFriendList();
    }
  }

  refreshFriendList() async {
    final friendRequestList = await userApi.getFriendRequestList();
    final guardianList = await userApi.getFriendList(1);
    final friendList = await userApi.getFriendList(0);

    if (friendRequestList.status == 200 &&
        guardianList.status == 200 &&
        friendList.status == 200) {
      state = BaseResponse(
          status: 200,
          message: "",
          data: FriendListModel(
              friendRequestList: friendRequestList.data ?? [],
              guardianList: guardianList.data ?? [],
              friendList: friendList.data ?? []));
    }
  }

  getFriendRequestList() async {
    final response = await userApi.getFriendRequestList();
    if (response.status == 200) {
      state = response;
    }
  }

  getFriendList(int isGuardian) async {
    final response = await userApi.getFriendList(isGuardian);
    if (response.status == 200) {
      state = response;
    }
  }

  searchFriend(String phoneNumber) async {
    final response = await userApi
        .searchFriend(SearchFriendRequestDto(phoneNumber: phoneNumber));
    if (response.status == 200) {
      state = response;
    }
  }

  deleteFriend(int friendId) async {
    final int userId =
        int.parse(await secureStorage.read(key: USER_ID).toString());
    final response = await userApi.deleteFriend(
        FriendRequestRequestDto(userId: userId, friendId: friendId));
    if (response.status == 200) {
      state = response;
    }
  }

  requestFriend(int friendId) async {
    final int userId =
        int.parse(await secureStorage.read(key: USER_ID).toString());
    final response = await userApi.requestFriend(
        FriendRequestRequestDto(userId: userId, friendId: friendId));
    state = response;
    logger.d(response.message);
  }

  acceptFriend(int friendId) async {
    final int userId =
        int.parse(await secureStorage.read(key: USER_ID).toString());
    final response = await userApi.acceptFriendRequest(
        FriendRequestRequestDto(userId: userId, friendId: friendId));
    if (response.status == 200) {
      state = response;
    }
  }

  denyFriend(int friendId) async {
    final int userId =
        int.parse(await secureStorage.read(key: USER_ID).toString());
    final response = await userApi.denyFriendRequest(
        FriendRequestRequestDto(userId: userId, friendId: friendId));
    if (response.status == 200) {
      state = response;
    }
  }

  editGuardian(int friendId) async {
    final int userId =
        int.parse(await secureStorage.read(key: USER_ID).toString());
    final response = await userApi.editGuardian(
        FriendRequestRequestDto(userId: userId, friendId: friendId));
    if (response.status == 200) {
      state = response;
    }
  }
}
