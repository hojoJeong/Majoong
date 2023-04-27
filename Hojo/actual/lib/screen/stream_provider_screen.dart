import 'package:actual/riverpod/StreamProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../layout/default_layout.dart';

class StreamProviderScreen extends ConsumerWidget {
  const StreamProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(multipleStreamProvider);
    return DefaultLayout(
      title: 'StreamProviderScreen',
      body: Center(
        child: state.when(
            data: (data) => Text(data.toString()),
            error: (err, stackTrace) => Text(err.toString()),
            loading: () => CircularProgressIndicator()),
      ),
      actions: [],
    );
  }
}
