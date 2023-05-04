import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/user/login_request_dto.dart';

final loginRequestStateProvider =
    StateProvider<LoginRequestDto>((ref) => LoginRequestDto(socialPK: "-1"));
