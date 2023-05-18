import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:majoong/viewmodel/search/search_route_point_provider.dart';
import 'package:majoong/viewmodel/search/search_route_provider.dart';

class ErrorSearchRouteScreen extends ConsumerWidget {
  final String err;
  const ErrorSearchRouteScreen({Key? key, required this.err}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(searchRouteProvider.notifier).refreshState();
    ref.read(routePointProvider.notifier).refreshState();
    return DefaultLayout(title: '경로 검색 실패', body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Text(err, style: TextStyle(
          fontSize: BASE_TITLE_FONT_SIZE,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),),
      ),
    ));
  }
}
