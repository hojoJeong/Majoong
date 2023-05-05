import 'package:flutter/material.dart';
import 'package:majoong/common/layout/default_layout.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(title: '즐겨찾기', body: Text('즐겨찾기'));
  }
}
