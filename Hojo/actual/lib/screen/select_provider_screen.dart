import 'dart:ffi';

import 'package:actual/layout/default_layout.dart';
import 'package:actual/riverpod/select_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectProvierScreen extends ConsumerWidget {
  const SelectProvierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(selectProvider.select((value) => value.isSpicy));
    ref.listen(selectProvider.select((value) => value.hasBought), (previous, next) {
      print('next : $next');
    });

    return DefaultLayout(
        title: 'SelectProvierScreen',
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.toString()),
              // Text(state.name),
              // Text(state.isSpicy.toString()),
              // Text(state.hasBought.toString()),
              ElevatedButton(onPressed: (){
                ref.read(selectProvider.notifier).toggleIsSpicy();
              }, child: Text('spi toggle')),
              ElevatedButton(onPressed: (){
                ref.read(selectProvider.notifier).toggleHasBought();
              }, child: Text('hasbo toggle')),
            ],
          ),
        ),
        actions: []);
  }
}
