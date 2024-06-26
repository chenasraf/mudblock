import 'package:flutter/material.dart';

import '../core/features/alias.dart';
import '../core/features/trigger.dart';
import '../core/store.dart';
import '../pages/about_page.dart';
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
  static const selectProfile = '/select-profile';

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
  static const about = '/about';
}

final routes = <String, Widget Function(BuildContext)>{
  // profiles
  Paths.profiles: (context) => const SelectProfilePage(),
  Paths.profile: (context) {
    final profile = ModalRoute.of(context)!.settings.arguments as MUDProfile?;
    return ProfilePage(profile: profile);
  },
  Paths.selectProfile: (context) => const SelectProfilePage(),

  // aliases
  Paths.aliases: (context) => GameStore.consumer(
        builder: (context, store, child) => AliasListPage(
          aliases: store.currentProfile.aliases,
          onSave: (alias) async {
            store.currentProfile.saveAlias(alias);
          },
          onDelete: (alias) async {
            store.currentProfile.deleteAlias(alias);
          },
        ),
      ),
  Paths.alias: (context) {
    final alias = ModalRoute.of(context)!.settings.arguments as Alias?;
    return GameStore.consumer(
      builder: (context, store, child) => AliasPage(
        alias: alias,
        onSave: (alias) async {
          store.currentProfile.saveAlias(alias);
        },
      ),
    );
  },

  // triggers
  Paths.triggers: (context) => GameStore.consumer(
        builder: (context, store, child) => TriggerListPage(
          triggers: store.currentProfile.triggers,
          onSave: (trigger) async {
            store.currentProfile.saveTrigger(trigger);
          },
          onDelete: (trigger) async {
            store.currentProfile.deleteTrigger(trigger);
          },
        ),
      ),
  Paths.trigger: (context) {
    final trigger = ModalRoute.of(context)!.settings.arguments as Trigger?;
    return GameStore.consumer(
      builder: (context, store, child) => TriggerPage(
        trigger: trigger,
        onSave: (trigger) async {
          store.currentProfile.saveTrigger(trigger);
        },
      ),
    );
  },

  // variables
  Paths.variables: (context) => GameStore.consumer(
        builder: (context, store, child) => VariableListPage(
          variables: store.currentProfile.variables.values.toList(),
          onSave: (variable) async {
            store.currentProfile.saveVariable(variable.name, variable.value);
          },
        ),
      ),
  Paths.variable: (context) {
    final variable = ModalRoute.of(context)!.settings.arguments as Variable?;
    return VariablePage(variable: variable);
  },

  // buttons
  Paths.buttons: (context) => GameStore.consumer(
        builder: (context, store, child) {
          return ButtonSetListPage(
            buttonSets: store.currentProfile.buttonSets,
            onSave: (buttonSet) async {
              store.currentProfile.saveButtonSet(buttonSet);
            },
            onDelete: (buttonSet) async {
              store.currentProfile.deleteButtonSet(buttonSet);
            },
          );
        },
      ),
  Paths.buttonSet: (context) {
    final buttonSet =
        ModalRoute.of(context)!.settings.arguments as GameButtonSetData?;
    return GameButtonSetPage(buttonSet: buttonSet);
  },

  // shortcuts
  Paths.shortcuts: (context) {
    return GameStore.consumer(
      builder: (context, store, child) => KeyboardShortcutsPage(
        map: store.currentProfile.keyboardShortcuts,
        onSave: (shortcuts) {
          store.currentProfile.saveKeyboardShortcuts(shortcuts);
        },
      ),
    );
  },

  // settings
  Paths.settings: (context) {
    return GameStore.consumer(
      builder: (context, store, child) => SettingsPage(
        settings: store.connected ? store.currentProfile.settings : null,
        globalSettings: store.globalSettings,
        onSave: (settings, globalSettings) async {
          Navigator.pop(context);
          normal() async {
            if (settings == null) {
              return;
            }
            final old = store.currentProfile.settings.copyWith();
            await store.currentProfile.saveSettings(settings);
            store.echoSettingsChanged(old, settings);
          }

          global() async {
            final old = store.globalSettings.copyWith();
            await store.saveGlobalSettings(globalSettings);
            store.echoGlobalSettingsChanged(old, globalSettings);
          }

          await Future.wait([normal(), global()]);
        },
      ),
    );
  },

  // about
  Paths.about: (context) => const AboutPage(),

  // home
  Paths.home: (context) => HomeScaffold(
        builder: (context, _) {
          return const HomePage();
        },
      ),
};

