import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/user/edit_user_info_request_dto.dart';

final editUserInfoRequestDtoProvider = StateProvider((ref) =>
    EditUserInfoRequestDto(nickname: '', phoneNumber: '', profileImage: null));
