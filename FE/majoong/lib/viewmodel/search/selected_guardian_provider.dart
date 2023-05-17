import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/util/logger.dart';

final selectedGuardianProvider = StateNotifierProvider<SelectGuardianStateNotifier, List<int>>((ref) {
  final notifier = SelectGuardianStateNotifier();
  return notifier;
});

class SelectGuardianStateNotifier extends StateNotifier<List<int>> {
  SelectGuardianStateNotifier() : super([]);

  List<int> guardianList = [];

  editGuardian(int userId) {
    if (guardianList.contains(userId)) {
      guardianList.remove(userId);
    } else {
      guardianList.add(userId);
    }
    state = guardianList;
    logger.d('보호자 리스트 : ${state.length}');
  }
}
