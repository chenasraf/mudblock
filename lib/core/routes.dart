import 'package:flutter/material.dart';
import 'package:mudblock/core/consts.dart';

import '../core/features/alias.dart';
import '../core/features/trigger.dart';
import '../core/store.dart';
import '../pages/alias_list_page.dart';
import '../pages/alias_page.dart';
import '../pages/home_page.dart';
import '../pages/home_scaffold.dart';
import '../pages/profile_page.dart';
import '../pages/select_profile_page.dart';
import '../pages/trigger_list_page.dart';
import '../pages/trigger_page.dart';
import '../pages/variable_list_page.dart';
import '../pages/variable_page.dart';
import 'features/profile.dart';
import 'features/variable.dart';

class Paths {
  static const home = '/';

  static const profiles = '/profiles';
  static const profile = '/profile';

  static const aliases = '/aliases';
  static const alias = '/alias';

  static const triggers = '/triggers';
  static const trigger = '/trigger';

  static const variables = '/variables';
  static const variable = '/variable';

  static const settings = '/settings';
}

final routes = <String, Widget Function(BuildContext)>{
  Paths.profiles: (context) => const SelectProfilePage(),
  Paths.profile: (context) {
    final profile = ModalRoute.of(context)!.settings.arguments as MUDProfile?;
    return ProfilePage(profile: profile);
  },
  Paths.aliases: (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const AliasListPage();
        },
      ),
  Paths.alias: (context) {
    final alias = ModalRoute.of(context)!.settings.arguments as Alias?;
    return AliasPage(alias: alias);
  },
  Paths.triggers: (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const TriggerListPage();
        },
      ),
  Paths.trigger: (context) {
    final trigger = ModalRoute.of(context)!.settings.arguments as Trigger?;
    return TriggerPage(trigger: trigger);
  },
  Paths.variables: (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const VariableListPage();
        },
      ),
  Paths.variable: (context) {
    final variable = ModalRoute.of(context)!.settings.arguments as Variable?;
    return VariablePage(variable: variable);
  },
  Paths.home: (context) => HomeScaffold(
        builder: (context, _) {
          return HomePage(key: homeKey);
        },
      ),
};

