import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final String title;
  final Widget body;
  final List<Widget> actions;

  const DefaultLayout(
      {
        this.backgroundColor,
        required this.title,
        required this.body,
        required this.actions,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body:
      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: body),
    );
  }

}
