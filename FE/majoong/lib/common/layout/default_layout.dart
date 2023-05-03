import 'package:flutter/material.dart';
import 'package:majoong/common/const/size_value.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final String title;
  final Widget body;
  final List<Widget> actions;

  const DefaultLayout(
      {this.backgroundColor,
      required this.title,
      required this.body,
      required this.actions,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title,
        ),
        actions: actions,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BASE_PADDING),
          child: body),
    );
  }
}
