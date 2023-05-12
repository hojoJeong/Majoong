import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';

import '../../model/response/base_response.dart';

class OnGoingScreen extends ConsumerStatefulWidget {
  const OnGoingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingState();
}

class _OnGoingState extends ConsumerState<OnGoingScreen> {
  @override
  Widget build(BuildContext context) {
    final shareLocationState = ref.watch(shareLocationProvider);
    logger.d('amqp share locationstate : $shareLocationState');
    if (shareLocationState is BaseResponse<bool>) {
      logger.d('amqp share location state is baseResponse<bool>');

      Timer.periodic(Duration(seconds: 1), (timer) async {
        logger.d('amqp timer : ${timer.tick}');
        final curLocation = await Location.instance.getLocation();
        final lat = curLocation.latitude!;
        final lng = curLocation.longitude!;
        logger.d('amqp cur location : $lat, $lng');
        ref.read(shareLocationProvider.notifier).sendLocation(lat, lng);
      });
      return Scaffold(
        body: Text('이동중 화면'),
      );
    } else {
      return LoadingLayout();
    }


  }
}
