import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/service/local/recent_keyword_storage.dart';

class RecentKeywordWidget extends ConsumerWidget {
  final String keyword;

  const RecentKeywordWidget({Key? key, required this.keyword})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: (){
            logger.d('keyword : $keyword');
          },
          child: Text(
            keyword,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        GestureDetector(
          onTap: (){
            logger.d('검색 기록 삭제 : $keyword');
            ref.read(recentKeywordProvider.notifier).deleteKeyword(keyword);
          },
            child: Icon(Icons.clear)),
      ],
    );
  }
}
