import 'package:actual/model/shopping_item_model.dart';
import 'package:actual/riverpod/state_notifier_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredShoppingListProvider = Provider<List<ShoppingItemModel>>((ref) {
  final filterState = ref.watch(filterProvider);
  final shoppingListState = ref.watch(shoppingListProvider);

  if (filterState == FilterState.all) {
    return shoppingListState;
  } else {
    return shoppingListState
        .where((element) => filterState == FilterState.spicy
            ? element.isSpicy
            : !element.isSpicy)
        .toList();
  }
});

enum FilterState { notSpicy, spicy, all }

final filterProvider = StateProvider((ref) => FilterState.all);
