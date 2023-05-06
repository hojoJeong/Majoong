import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/component/signle_button_widget.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/favorite/favorite_response_dto.dart';
import 'package:majoong/viewmodel/favorite/favorite_list_provider.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final favoriteListState = ref.watch(favoriteListStateProvider);
    ///임시 데이터
    final List<FavoriteResponseDto> favoriteListState = [
      FavoriteResponseDto(
          favoriteId: 1,
          locationName: '사피',
          address: '경북 구미시 진평5길 23asdfasdfas sdfsf fsdfsdf'),
      FavoriteResponseDto(
          favoriteId: 1, locationName: '사피', address: '경북 구미시 진평5길 23'),
      FavoriteResponseDto(
          favoriteId: 1, locationName: '사피', address: '경북 구미시 진평5길 23'),
      FavoriteResponseDto(
          favoriteId: 1, locationName: '사피', address: '경북 구미시 진평5길 23'),
    ]; // if (favoriteListState is BaseResponse<List<FavoriteResponseDto>>) {
    return DefaultLayout(
        title: '즐겨찾기',
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    if (favoriteListState.isEmpty) {
                      return Text('등록된 즐겨찾기가 없습니다.');
                    } else {
                      final favoriteItem = favoriteListState[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image(
                            image: AssetImage('res/icon_favorite.png'),
                            width: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favoriteItem.locationName,
                                style: TextStyle(
                                    fontSize: BASE_TITLE_FONT_SIZE,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  favoriteItem.address,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(favoriteListStateProvider.notifier)
                                  .deleteFavorite(favoriteItem.favoriteId);
                            },
                            child: Icon(Icons.clear),
                          )
                        ],
                      );
                    }
                  },
                  separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: BASE_MARGIN_TITLE_TO_CONTENT),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                  itemCount: favoriteListState.length),
            ),
            Spacer(),
            SingleButtonWidget(
                content: '뒤로가기',
                onPressed: () => Navigator.pop(context))
          ],
        ));
    // } else {
    //   return Container(
    //     decoration: BoxDecoration(color: Colors.grey),
    //     child: LoadingLayout(),
    //   );
    // }
  }

}
