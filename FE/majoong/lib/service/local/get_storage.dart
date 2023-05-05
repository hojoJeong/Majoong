import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/util/logger.dart';

final recentKeywordProvider =
    StateNotifierProvider<RecentKeywordStateNotifier, List<String>>((ref) {
  final storage = GetStorage();
  final notifier = RecentKeywordStateNotifier(storage: storage);
  return notifier;
});

class RecentKeywordStateNotifier extends StateNotifier<List<String>> {
  final GetStorage storage;

  RecentKeywordStateNotifier({required this.storage}) : super([]);

  initKeyword() async {
    state = await storage.read(RECENT_KEYWORD);
    logger.d('초기 키워드 : ${state.length}');
  }

  addKeyword(String keyword) async {
    List<String> keywordList = [];
    if(storage.hasData(RECENT_KEYWORD)){
       keywordList = (storage.read(RECENT_KEYWORD) as List<dynamic>).cast<String>();
    }
    keywordList.add(keyword);
    await storage.write(RECENT_KEYWORD, keywordList);
    state = keywordList;
    logger.d('키워드 업데이터 : $keyword, ${state.length}');
  }

  deleteKeyword(String keyword) async {
    final List<String> keywordList = (storage.read(RECENT_KEYWORD) as List<dynamic>).cast<String>();
    keywordList.remove(keyword);
    await storage.write(RECENT_KEYWORD, keywordList);
    state = keywordList;
  }

}
