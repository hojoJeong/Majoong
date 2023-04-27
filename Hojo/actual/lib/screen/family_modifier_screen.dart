import 'package:actual/layout/default_layout.dart';
import 'package:actual/riverpod/family_modifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyModifierScreen extends ConsumerWidget {
  const FamilyModifierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyModifierProvider(5));
    return DefaultLayout(
        title: 'Family',
        body: Center(
            child: state.when(
                data: (data) => Text(data.toString()),
                error: (err, stack) => Text(err.toString()),
                loading: () => CircularProgressIndicator())),
        actions: []);
  }
}
