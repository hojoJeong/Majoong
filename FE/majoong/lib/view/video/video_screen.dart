import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:majoong/common/layout/default_layout.dart';
class VideoScreen extends ConsumerWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultLayout(title: '녹화 기록', body: Container());
  }
}
