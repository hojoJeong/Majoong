import 'package:actual/layout/default_layout.dart';
import 'package:actual/screen/auto_dispose_modifier_screen.dart';
import 'package:actual/screen/family_modifier_screen.dart';
import 'package:actual/screen/future_provider_screen.dart';
import 'package:actual/screen/listen_provider_screen.dart';
import 'package:actual/screen/provider_screen.dart';
import 'package:actual/screen/select_provider_screen.dart';
import 'package:actual/screen/state_notifier_provider_screen.dart';
import 'package:actual/screen/state_provider_screen.dart';
import 'package:actual/screen/stream_provider_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'homeScreen',
      body: ListView(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StateProviderScreen()));
              },
              child: Text('StateProviderScreen')),
          ElevatedButton(onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StateProviderScreen()));
          }, child: Text('Next Screen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StateNotifierProviderScreen()));
              },
              child: Text('StateProviderScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FutureProviderScreen()));
              },
              child: Text('FutureProviderScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StreamProviderScreen()));
              },
              child: Text('StreamProviderScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FamilyModifierScreen()));
              },
              child: Text('familtModifierScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AutoDisposeModifierScreen()));
              },
              child: Text('AutoDisposeModifierScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ListenProviderSscreen()));
              },
              child: Text('ListenProviderSscreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SelectProvierScreen()));
              },
              child: Text('SelectProvierScreen')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProviderScreen()));
              },
              child: Text('ProviderScreen')),
        ],
      ),
      actions: [],
    );
  }
}
