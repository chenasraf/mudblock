import 'package:flutter/material.dart';
import 'package:mudblock/core/consts.dart';

import '../core/features/alias.dart';
import '../core/features/trigger.dart';
import '../core/store.dart';
import '../pages/alias_list_page.dart';
import '../pages/alias_page.dart';
import '../pages/home_page.dart';
import '../pages/home_scaffold.dart';
import '../pages/profile_select_page.dart';
import '../pages/trigger_list_page.dart';
import '../pages/trigger_page.dart';

final routes = <String, Widget Function(BuildContext)>{
  '/select-profile': (context) => const ProfileSelectPage(),
  '/aliases': (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const AliasListPage();
        },
      ),
  '/alias': (context) {
    final alias = ModalRoute.of(context)!.settings.arguments as Alias?;
    return AliasPage(alias: alias);
  },
  '/triggers': (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const TriggerListPage();
        },
      ),
  '/trigger': (context) {
    final trigger = ModalRoute.of(context)!.settings.arguments as Trigger?;
    return TriggerPage(trigger: trigger);
  },
  '/home': (context) => HomeScaffold(
        builder: (context, _) {
          return HomePage(key: homeKey);
        },
      ),
};

