import 'package:actual/riverpod/provider_observer.dart';
import 'package:actual/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [
        Logger()
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    )
  );
}
