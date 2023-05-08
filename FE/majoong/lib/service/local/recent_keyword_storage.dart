import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';

final recentKeywordProvider =
    StateNotifierProvider<RecentKeywordStateNotifier, BaseResponseState>((ref) {
  final storage = GetStorage();
  final notifier = RecentKeywordStateNotifier(storage: storage);
  return notifier;
});

class RecentKeywordStateNotifier extends StateNotifier<BaseResponseState> {
  final GetStorage storage;

  RecentKeywordStateNotifier({required this.storage})
      : super(BaseResponseLoading()) {
      initKeyword();
  }

  initKeyword() async {
    List<String> keywordList = [];
    logger.d('init keyword : $state, length : ${keywordList.length}');
    if (storage.hasData(RECENT_KEYWORD)) {
      keywordList =
          (storage.read(RECENT_KEYWORD) as List<dynamic>).cast<String>();
      logger.d('init keyword : $state');
    }
    state = BaseResponse(status: 200, message: '', data: keywordList);
    logger.d('init keyword : $state, length : ${keywordList.length}');
  }

  addKeyword(String keyword) async {
    List<String> keywordList = [];
    if (storage.hasData(RECENT_KEYWORD)) {
      keywordList =
          (storage.read(RECENT_KEYWORD) as List<dynamic>).cast<String>();
    }
    if (keywordList.contains(keyword)) {
      keywordList.remove(keyword);
    }
    keywordList.insert(0, keyword);
    if (keywordList.length >= 11) {
      keywordList.removeAt(10);
    }
    await storage.write(RECENT_KEYWORD, keywordList);
    state = BaseResponse(status: 200, message: '', data: keywordList);
    logger.d('키워드 업데이트 : $keyword');
  }

  deleteKeyword(String keyword) async {
    final List<String> keywordList =
        (storage.read(RECENT_KEYWORD) as List<dynamic>).cast<String>();
    keywordList.remove(keyword);
    await storage.write(RECENT_KEYWORD, keywordList);
    state = BaseResponse(status: 200, message: '', data: keywordList);
  }
}
