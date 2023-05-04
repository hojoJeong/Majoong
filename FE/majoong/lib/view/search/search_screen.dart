import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/view/search/favorite_widget.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultLayout(
        title: '검색',
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '즐겨찾기 목록',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: BASE_TITLE_FONT_SIZE,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        //TODO 즐겨찾기 목록 페이지 이동
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavoriteWidget(
                                      name: '임시',
                                      address: '123asdfasdfasdf',
                                    )));
                      },
                      child: Text(
                        '수정하기',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
