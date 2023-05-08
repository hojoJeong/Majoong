import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/user/delete_notification_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/service/remote/api/user/user_api_service.dart';

final notificationProvider =
    StateNotifierProvider<NotificationStateNotifier, BaseResponseState>((ref) {
  final userApi = ref.read(userApiServiceProvider);
  final notifier = NotificationStateNotifier(userApi: userApi);
  return notifier;
});

class NotificationStateNotifier extends StateNotifier<BaseResponseState> {
  final UserApiService userApi;

  NotificationStateNotifier({required this.userApi})
      : super(BaseResponseLoading()) {
    getNotificationList();
  }

  getNotificationList() async {
    final response = await userApi.getNotificationList();
    if (response.status == 200) {
      state = response;
    }
  }

  deleteNotification(String notificationId) async {
    final response = await userApi.deleteNotification(
        DeleteNotificationRequestDto(notificationId: notificationId));
    if (response.status == 200) {
      state = response;
    }
  }
}
