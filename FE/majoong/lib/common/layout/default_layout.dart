import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/layout/loading_visibility_provider.dart';

class DefaultLayout extends ConsumerWidget {
  final Color? backgroundColor;
  final String title;
  final Widget body;

  const DefaultLayout({this.backgroundColor,
    required this.title,
    required this.body,
    Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingVisibility = ref.watch(loadingVisibilityProvider);
    return Scaffold(

        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor ?? Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Text(
            title,
          ),
        ),
        body: Stack(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: BASE_PADDING),
                child: body),
            Visibility(visible: loadingVisibility,
                child: LoadingLayout())
          ],
        )
    );
  }
}