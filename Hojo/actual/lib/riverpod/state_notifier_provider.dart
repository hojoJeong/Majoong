import 'package:actual/model/shopping_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItemModel>>(
        (ref) => ShoppingListNotifier());

class ShoppingListNotifier extends StateNotifier<List<ShoppingItemModel>> {
  ShoppingListNotifier()
      : super([
          ShoppingItemModel(
              name: '김치', quantity: 3, hasBought: false, isSpicy: true),
          ShoppingItemModel(
              name: '삼겹살', quantity: 3, hasBought: true, isSpicy: true),
          ShoppingItemModel(
              name: '라면', quantity: 3, hasBought: false, isSpicy: false),
          ShoppingItemModel(
              name: '수박', quantity: 3, hasBought: false, isSpicy: true),
          ShoppingItemModel(
              name: '고기', quantity: 3, hasBought: false, isSpicy: true),
        ]);

  void toggleHasBought({required String name}) {
    state = state
        .map((e) => e.name == name
            ? ShoppingItemModel(
                name: e.name,
                quantity: e.quantity,
                hasBought: !e.hasBought,
                isSpicy: e.isSpicy)
            : e)
        .toList();
  }
}