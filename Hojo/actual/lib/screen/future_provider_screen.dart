import 'package:actual/layout/default_layout.dart';
import 'package:actual/riverpod/future_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FutureProviderScreen extends ConsumerWidget {
  const FutureProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(multipleFutureProvider);

    return DefaultLayout(
        title: 'FutureProviderScreen',
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            state.when(
                data: (data) {
                  return Text(
                    data.toString(),
                    textAlign: TextAlign.center,
                  );
                },
                error: (err, stack) => Text(err.toString()),
                loading: () => Center(child: CircularProgressIndicator()))
          ],
        ),
        actions: []);
  }
}
