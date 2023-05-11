import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';

import '../../model/response/base_response.dart';

class OnGoingScreen extends ConsumerStatefulWidget {
  const OnGoingScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingState();
}

class _OnGoingState extends ConsumerState<OnGoingScreen>{

  @override
  Widget build(BuildContext context) {

    final shareLocationState = ref.watch(shareLocationProvider);

    if(shareLocationState is BaseResponse<bool>){
      Timer.periodic(Duration(seconds: 2), (timer) {
        logger.d('시간초 : ${timer.tick}');
        ref.read(shareLocationProvider.notifier).sendLocation(0, 0);
      });
    }

    return Scaffold(
      body: Text('이동중 화면'),
    );
  }
}
