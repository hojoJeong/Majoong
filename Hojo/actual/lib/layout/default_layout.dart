import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DefaultLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;

  const DefaultLayout({
    required this.title,
    required this.body,
    required this.actions,
    Key? key
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: body),
    );
  }
}
