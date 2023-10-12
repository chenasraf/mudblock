import 'package:flutter/material.dart';

import '../core/features/alias.dart';
import '../core/features/trigger.dart';
import '../core/store.dart';
import '../pages/alias_list_page.dart';
import '../pages/alias_page.dart';
import '../pages/button_set_page.dart';
import '../pages/button_sets_list_page.dart';
import '../pages/home_page.dart';
import '../pages/home_scaffold.dart';
import '../pages/keyboard_shortcuts_page.dart';
import '../pages/profile_page.dart';
import '../pages/select_profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/trigger_list_page.dart';
import '../pages/trigger_page.dart';
import '../pages/variable_list_page.dart';
import '../pages/variable_page.dart';
import 'features/game_button_set.dart';
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

  static const buttons = '/buttons';
  static const buttonSet = '/button-set';
  static const button = '/button';

  static const shortcuts = '/shortcuts';

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
  Paths.buttons: (context) => GameStore.consumer(
        builder: (context, store, child) {
          return const ButtonSetListPage();
        },
      ),
  Paths.buttonSet: (context) {
    final buttonSet =
        ModalRoute.of(context)!.settings.arguments as GameButtonSetData?;
    return GameButtonSetPage(buttonSet: buttonSet);
  },
  Paths.shortcuts: (context) {
    return GameStore.consumer(builder: (context, store, child) {
      return KeyboardShortcutsPage(
        shortcuts: store.keyboardShortcuts,
        onSave: (shortcuts) {
          store.keyboardShortcuts = shortcuts;
          store.currentProfile.saveKeyboardShortcuts(shortcuts);
        },
      );
    });
  },
  Paths.settings: (context) {
    return const SettingsPage();
  },
  Paths.home: (context) => HomeScaffold(
        builder: (context, _) {
          return const HomePage();
        },
      ),
};

