import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/request/sign_up_request_dto.dart';

final signUpRequestDtoProvider = StateProvider((ref) => SignUpRequestDto(
    nickname: '',
    phoneNumber: '',
    profileImage: '',
    pinNumber: '',
    socialPK: ''));
