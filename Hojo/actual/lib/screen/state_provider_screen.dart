import 'package:actual/layout/default_layout.dart';
import 'package:actual/riverpod/state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateProviderScreen extends ConsumerWidget {
  const StateProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(numberProvider);

    return DefaultLayout(
      title: 'StateProviderScreen',
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.toString()),
            ElevatedButton(onPressed: (){
              ref.read(numberProvider.notifier).update((state) => state+1);
            }, child: Text(
              'up'
            )),
            ElevatedButton(onPressed: (){
              ref.read(numberProvider.notifier).state = ref.read(numberProvider.notifier).state -1;
            }, child: Text(
                'down'
            )),
          ],
        ),
      ), actions: [],
    );
  }
}

class NextScreen extends ConsumerWidget {
  const NextScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(numberProvider);

    return DefaultLayout(
      title: 'StateProviderScreen',
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.toString()),
            ElevatedButton(onPressed: (){
              ref.read(numberProvider.notifier).update((state) => state+1);
            }, child: Text(
                'up'
            ))
          ],
        ),
      ), actions: [],
    );
  }
}