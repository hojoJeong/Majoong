import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';

class OnGoingScreen extends ConsumerStatefulWidget {
  const OnGoingScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingState();
}

class _OnGoingState extends ConsumerState<OnGoingScreen>{
  @override
  Widget build(BuildContext context) {
    ref.read(shareLocationProvider.notifier).sendLocation(0, 0);
    return Scaffold(
      body: Text('이동중 화면'),
    );
  }
}
