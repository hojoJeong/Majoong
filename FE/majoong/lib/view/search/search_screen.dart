import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/favorite/favorite_response_dto.dart';
import 'package:majoong/service/local/recent_keyword_storage.dart';
import 'package:majoong/view/favorite/favorite_screen.dart';
import 'package:majoong/view/search/favorite_widget.dart';
import 'package:majoong/view/search/recent_keyword_widget.dart';
import 'package:majoong/view/search/result_search_places_screen.dart';
import 'package:majoong/viewmodel/favorite/favorite_list_provider.dart';
import 'package:majoong/viewmodel/search/recent_keyword_provider.dart';
import 'package:majoong/viewmodel/search/search_route_point_provider.dart';

class SearchScreen extends ConsumerWidget {
  SearchScreen({Key? key}) : super(key: key);
  TextEditingController searchKeywordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteListState = ref.watch(favoriteListStateProvider);
    final recentKeywordListState = ref.watch(recentKeywordProvider);

    Future.delayed(Duration.zero, () {
      if (ref.read(keywordProvider) != "") {
        ref.read(keywordProvider.notifier).update((state) => "");
      }
    });
    ref.listen(keywordProvider, (previous, next) {
      searchKeywordController.text = next;
    });

    if (favoriteListState is BaseResponse && recentKeywordListState is BaseResponse) {
      return Scaffold(
          body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchKeywordController,
                      decoration: InputDecoration(
                          hintText: '위치를 검색해주세요',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                if(searchKeywordController.text.isEmpty){
                                  showToast(context: context, '검색어를 입력해주세요.');
                                } else {
                                  ref.read(recentKeywordProvider.notifier).addKeyword(searchKeywordController.text);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => ResultSearchPlacesScreen(
                                          keyword:
                                          searchKeywordController.text)));
                                }
                                
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(Icons.search, size: 30,),
                              ))),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BASE_PADDING),
              child: Row(
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoriteScreen()));
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
            ),
            favoriteListView(favoriteListState.data, context),
            // Expanded(child: makeFavoriteList(favoriteListState.data))

            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BASE_PADDING),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(recentKeywordProvider.notifier).addKeyword('스벅');
                    },
                    child: Text(
                      '최근 검색 기록',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: BASE_TITLE_FONT_SIZE,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            recentKeywordListView(
                (recentKeywordListState.data as List<dynamic>).cast<String>())
          ],
        ),
      ));
    } else {
      logger.d(recentKeywordListState);
      return Container(
          color: Colors.grey,
          child: LoadingLayout());
    }
  }

  Widget favoriteListView(
      List<FavoriteResponseDto> favoriteList, BuildContext context) {
    if (favoriteList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: BASE_MARGIN_CONTENTS_TO_CONTENTS),
        child: Text('등록된 장소가 없습니다.'),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: favoriteList.length,
          padding: EdgeInsets.all(BASE_PADDING),
          itemBuilder: (context, index) {
            logger.d(
                'favorite item : ${favoriteList[index].locationName}, ${favoriteList[index].address}');
            final favoriteItem = favoriteList[index];
            return FavoriteWidget(
                name: favoriteItem.locationName, address: favoriteItem.address);
          },
          separatorBuilder: (context, index) => VerticalDivider(
            thickness: 1,
          ),
        ),
      );
    }
  }

  Widget recentKeywordListView(List<String> recentKeywordList) {
    logger.d('키워드 recentKeywordLength : ${recentKeywordList.length}');
    if (recentKeywordList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: BASE_MARGIN_CONTENTS_TO_CONTENTS),
        child: Text('검색 기록이 없습니다'),
      );
    } else {
      return Expanded(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: recentKeywordList.length,
          padding: EdgeInsets.all(BASE_PADDING),
          itemBuilder: (context, index) {
            final keyword = recentKeywordList[index];
            return RecentKeywordWidget(keyword: keyword);
          },
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ),
      );
    }
  }
}
