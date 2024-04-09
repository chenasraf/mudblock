import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/store.dart';
import 'home_app_bar.dart';
import 'home_drawer.dart';

class HomeScaffold extends StatelessWidget with GameStoreMixin {
  final Widget Function(BuildContext, Widget?) builder;

  const HomeScaffold({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: ChangeNotifierProvider.value(
        value: gameStore,
        builder: builder,
      ),
      endDrawer: const HomeDrawer(),
    );
  }
}



