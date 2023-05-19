import 'package:flutter/material.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/util/logger.dart';

class SingleButtonWidget extends StatelessWidget {
  final String content;
  final VoidCallback? onPressed;

  const SingleButtonWidget(
      {Key? key, required this.content, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: POLICE_MARKER_COLOR,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          onPressed: onPressed != null ? () {
            onPressed!();
          } : null,
          child: Text(
            content,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: BASE_TITLE_FONT_SIZE),
          )),
    );
  }
}
