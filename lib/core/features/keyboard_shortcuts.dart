import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';

class KeyboardIntent extends Intent {
  const KeyboardIntent(this.key, [this.modifier]);

  final LogicalKeyboardKey key;
  final LogicalKeyboardKey? modifier;
}

/// An action that can be invoked by a [KeyboardIntent].
class KeyboardAction extends ContextAction<KeyboardIntent> with GameStoreMixin {
  @override
  void invoke(covariant KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) {
      return;
    }
    if (!isEnabled(intent, context)) {
      return;
    }
    final store = storeOf(context);
    store.onShortcut(context, intent.key, intent.modifier);
  }

  @override
  bool isEnabled(KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) {
      return false;
    }
    final store = storeOf(context);
    final action = store.currentProfile.keyboardShortcuts
        .getAction(intent.modifier, intent.key);
    bool isAux = false;
    for (final key in store.auxillaryIntents) {
      if (key.key == intent.key) {
        isAux = true;
        break;
      }
    }
    if (action.isEmpty && !isAux) {
      return false;
    }
    return super.isEnabled(intent, context);
  }
}

const numpadKeys = [
  LogicalKeyboardKey.numpad0,
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2,
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
  LogicalKeyboardKey.numpad5,
  LogicalKeyboardKey.numpad6,
  LogicalKeyboardKey.numpad7,
  LogicalKeyboardKey.numpad8,
  LogicalKeyboardKey.numpad9,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.numpadDecimal,
  LogicalKeyboardKey.numpadAdd,
  LogicalKeyboardKey.numpadSubtract,
  LogicalKeyboardKey.numpadMultiply,
  LogicalKeyboardKey.numpadDivide,
  LogicalKeyboardKey.numpadEqual,
];

/// A map of modifier keys and their respective keyboard mappings
class KeyboardShortcutMap {
  KeyboardShortcutMap(this.map);
  final Map<LogicalKeyboardKey?, KeyboardShortcut> map;

  factory KeyboardShortcutMap.empty() => KeyboardShortcutMap({});

  factory KeyboardShortcutMap.fromJson(Map<String, dynamic> json) {
    final map = <LogicalKeyboardKey?, KeyboardShortcut>{};
    for (final entry in json.entries) {
      final key = numpadKeyLabels.containsValue(entry.key)
          ? numpadKeyLabels.entries.firstWhere((e) => e.value == entry.key).key
          : null;
      map[key] = KeyboardShortcut.fromJson(entry.value);
    }
    return KeyboardShortcutMap(map);
  }

  KeyboardShortcutMap copyWith(
          [Map<LogicalKeyboardKey?, KeyboardShortcut>? map]) =>
      KeyboardShortcutMap({...this.map, ...(map ?? {})});

  KeyboardShortcut getShortcut(LogicalKeyboardKey? modifier) =>
      map[modifier] ?? KeyboardShortcut.empty();

  String getAction(LogicalKeyboardKey? modifier, LogicalKeyboardKey key) =>
      getShortcut(modifier).get(key);

  Map<String, dynamic> toJson() => {
        for (final entry in map.entries)
          if (entry.value.isNotEmpty)
            numpadKeyLabels[entry.key] ?? 'None': entry.value.toJson(),
      };

  operator [](LogicalKeyboardKey? modifier) => getShortcut(modifier);
  operator []=(LogicalKeyboardKey? modifier, KeyboardShortcut shortcut) =>
      map[modifier] = shortcut;
}

class KeyboardShortcut {
  String numpad0;
  String numpad1;
  String numpad2;
  String numpad3;
  String numpad4;
  String numpad5;
  String numpad6;
  String numpad7;
  String numpad8;
  String numpad9;
  String numpadEnter;
  String numpadDecimal;
  String numpadAdd;
  String numpadSubtract;
  String numpadMultiply;
  String numpadDivide;
  String numpadEqual;

  KeyboardShortcut({
    required this.numpad0,
    required this.numpad1,
    required this.numpad2,
    required this.numpad3,
    required this.numpad4,
    required this.numpad5,
    required this.numpad6,
    required this.numpad7,
    required this.numpad8,
    required this.numpad9,
    required this.numpadEnter,
    required this.numpadDecimal,
    required this.numpadAdd,
    required this.numpadSubtract,
    required this.numpadMultiply,
    required this.numpadDivide,
    required this.numpadEqual,
  });

  factory KeyboardShortcut.empty() => KeyboardShortcut(
        numpad0: '',
        numpad1: '',
        numpad2: '',
        numpad3: '',
        numpad4: '',
        numpad5: '',
        numpad6: '',
        numpad7: '',
        numpad8: '',
        numpad9: '',
        numpadEnter: '',
        numpadDecimal: '',
        numpadAdd: '',
        numpadSubtract: '',
        numpadMultiply: '',
        numpadDivide: '',
        numpadEqual: '',
      );

  String get(LogicalKeyboardKey key) =>
      {
        LogicalKeyboardKey.numpad0: numpad0,
        LogicalKeyboardKey.numpad1: numpad1,
        LogicalKeyboardKey.numpad2: numpad2,
        LogicalKeyboardKey.numpad3: numpad3,
        LogicalKeyboardKey.numpad4: numpad4,
        LogicalKeyboardKey.numpad5: numpad5,
        LogicalKeyboardKey.numpad6: numpad6,
        LogicalKeyboardKey.numpad7: numpad7,
        LogicalKeyboardKey.numpad8: numpad8,
        LogicalKeyboardKey.numpad9: numpad9,
        LogicalKeyboardKey.numpadEnter: numpadEnter,
        LogicalKeyboardKey.numpadDecimal: numpadDecimal,
        LogicalKeyboardKey.numpadAdd: numpadAdd,
        LogicalKeyboardKey.numpadSubtract: numpadSubtract,
        LogicalKeyboardKey.numpadMultiply: numpadMultiply,
        LogicalKeyboardKey.numpadDivide: numpadDivide,
        LogicalKeyboardKey.numpadEqual: numpadEqual,
      }[key] ??
      '';

  factory KeyboardShortcut.fromJson(Map<String, dynamic> json) {
    return KeyboardShortcut(
      numpad0: json['numpad0'] ?? '',
      numpad1: json['numpad1'] ?? '',
      numpad2: json['numpad2'] ?? '',
      numpad3: json['numpad3'] ?? '',
      numpad4: json['numpad4'] ?? '',
      numpad5: json['numpad5'] ?? '',
      numpad6: json['numpad6'] ?? '',
      numpad7: json['numpad7'] ?? '',
      numpad8: json['numpad8'] ?? '',
      numpad9: json['numpad9'] ?? '',
      numpadEnter: json['numpadEnter'] ?? '',
      numpadDecimal: json['numpadDecimal'] ?? '',
      numpadAdd: json['numpadAdd'] ?? '',
      numpadSubtract: json['numpadSubtract'] ?? '',
      numpadMultiply: json['numpadMultiply'] ?? '',
      numpadDivide: json['numpadDivide'] ?? '',
      numpadEqual: json['numpadEqual'] ?? '',
    );
  }

  bool get isEmpty => toJson().values.every((element) => element.isEmpty);
  bool get isNotEmpty => !isEmpty;

  Map<String, dynamic> toJson() {
    return {
      'numpad0': numpad0,
      'numpad1': numpad1,
      'numpad2': numpad2,
      'numpad3': numpad3,
      'numpad4': numpad4,
      'numpad5': numpad5,
      'numpad6': numpad6,
      'numpad7': numpad7,
      'numpad8': numpad8,
      'numpad9': numpad9,
      'numpadEnter': numpadEnter,
      'numpadDecimal': numpadDecimal,
      'numpadAdd': numpadAdd,
      'numpadSubtract': numpadSubtract,
      'numpadMultiply': numpadMultiply,
      'numpadDivide': numpadDivide,
      'numpadEqual': numpadEqual,
    };
  }

  KeyboardShortcut copyWith({
    String? numpad0,
    String? numpad1,
    String? numpad2,
    String? numpad3,
    String? numpad4,
    String? numpad5,
    String? numpad6,
    String? numpad7,
    String? numpad8,
    String? numpad9,
    String? numpadEnter,
    String? numpadDecimal,
    String? numpadAdd,
    String? numpadSubtract,
    String? numpadMultiply,
    String? numpadDivide,
    String? numpadEqual,
  }) =>
      KeyboardShortcut(
        numpad0: numpad0 ?? this.numpad0,
        numpad1: numpad1 ?? this.numpad1,
        numpad2: numpad2 ?? this.numpad2,
        numpad3: numpad3 ?? this.numpad3,
        numpad4: numpad4 ?? this.numpad4,
        numpad5: numpad5 ?? this.numpad5,
        numpad6: numpad6 ?? this.numpad6,
        numpad7: numpad7 ?? this.numpad7,
        numpad8: numpad8 ?? this.numpad8,
        numpad9: numpad9 ?? this.numpad9,
        numpadEnter: numpadEnter ?? this.numpadEnter,
        numpadDecimal: numpadDecimal ?? this.numpadDecimal,
        numpadAdd: numpadAdd ?? this.numpadAdd,
        numpadSubtract: numpadSubtract ?? this.numpadSubtract,
        numpadMultiply: numpadMultiply ?? this.numpadMultiply,
        numpadDivide: numpadDivide ?? this.numpadDivide,
        numpadEqual: numpadEqual ?? this.numpadEqual,
      );

  KeyboardShortcut copyWithMap(Map<LogicalKeyboardKey, String> map) => copyWith(
        numpad0: map[LogicalKeyboardKey.numpad0],
        numpad1: map[LogicalKeyboardKey.numpad1],
        numpad2: map[LogicalKeyboardKey.numpad2],
        numpad3: map[LogicalKeyboardKey.numpad3],
        numpad4: map[LogicalKeyboardKey.numpad4],
        numpad5: map[LogicalKeyboardKey.numpad5],
        numpad6: map[LogicalKeyboardKey.numpad6],
        numpad7: map[LogicalKeyboardKey.numpad7],
        numpad8: map[LogicalKeyboardKey.numpad8],
        numpad9: map[LogicalKeyboardKey.numpad9],
        numpadEnter: map[LogicalKeyboardKey.numpadEnter],
        numpadDecimal: map[LogicalKeyboardKey.numpadDecimal],
        numpadAdd: map[LogicalKeyboardKey.numpadAdd],
        numpadSubtract: map[LogicalKeyboardKey.numpadSubtract],
        numpadMultiply: map[LogicalKeyboardKey.numpadMultiply],
        numpadDivide: map[LogicalKeyboardKey.numpadDivide],
        numpadEqual: map[LogicalKeyboardKey.numpadEqual],
      );
}

const numpadKeysIntentMap = <ShortcutActivator, Intent>{
  // single
  SingleActivator(LogicalKeyboardKey.numpad0):
      KeyboardIntent(LogicalKeyboardKey.numpad0),
  SingleActivator(LogicalKeyboardKey.numpad1):
      KeyboardIntent(LogicalKeyboardKey.numpad1),
  SingleActivator(LogicalKeyboardKey.numpad2):
      KeyboardIntent(LogicalKeyboardKey.numpad2),
  SingleActivator(LogicalKeyboardKey.numpad3):
      KeyboardIntent(LogicalKeyboardKey.numpad3),
  SingleActivator(LogicalKeyboardKey.numpad4):
      KeyboardIntent(LogicalKeyboardKey.numpad4),
  SingleActivator(LogicalKeyboardKey.numpad5):
      KeyboardIntent(LogicalKeyboardKey.numpad5),
  SingleActivator(LogicalKeyboardKey.numpad6):
      KeyboardIntent(LogicalKeyboardKey.numpad6),
  SingleActivator(LogicalKeyboardKey.numpad7):
      KeyboardIntent(LogicalKeyboardKey.numpad7),
  SingleActivator(LogicalKeyboardKey.numpad8):
      KeyboardIntent(LogicalKeyboardKey.numpad8),
  SingleActivator(LogicalKeyboardKey.numpad9):
      KeyboardIntent(LogicalKeyboardKey.numpad9),
  SingleActivator(LogicalKeyboardKey.numpadDivide):
      KeyboardIntent(LogicalKeyboardKey.numpadDivide),
  SingleActivator(LogicalKeyboardKey.numpadMultiply):
      KeyboardIntent(LogicalKeyboardKey.numpadMultiply),
  SingleActivator(LogicalKeyboardKey.numpadSubtract):
      KeyboardIntent(LogicalKeyboardKey.numpadSubtract),
  SingleActivator(LogicalKeyboardKey.numpadAdd):
      KeyboardIntent(LogicalKeyboardKey.numpadAdd),
  SingleActivator(LogicalKeyboardKey.numpadDecimal):
      KeyboardIntent(LogicalKeyboardKey.numpadDecimal),
  SingleActivator(LogicalKeyboardKey.numpadEnter):
      KeyboardIntent(LogicalKeyboardKey.numpadEnter),

  // shift
  SingleActivator(LogicalKeyboardKey.numpad0, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad0, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad1, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad1, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad2, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad2, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad3, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad3, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad4, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad4, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad5, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad5, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad6, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad6, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad7, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad7, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad8, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad8, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpad9, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpad9, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadDivide, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpadDivide, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadMultiply, shift: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadMultiply, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadSubtract, shift: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadSubtract, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadAdd, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpadAdd, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadDecimal, shift: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadDecimal, LogicalKeyboardKey.shift),
  SingleActivator(LogicalKeyboardKey.numpadEnter, shift: true):
      KeyboardIntent(LogicalKeyboardKey.numpadEnter, LogicalKeyboardKey.shift),

  // control/cmd
  SingleActivator(LogicalKeyboardKey.numpad0, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad0, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad1, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad1, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad2, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad2, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad3, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad3, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad4, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad4, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad5, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad5, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad6, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad6, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad7, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad7, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad8, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad8, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad9, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpad9, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadDivide, control: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadDivide, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadMultiply, control: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadMultiply, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadSubtract, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadAdd, control: true):
      KeyboardIntent(LogicalKeyboardKey.numpadAdd, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadDecimal, control: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadDecimal, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpadEnter, control: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadEnter, LogicalKeyboardKey.control),
  SingleActivator(LogicalKeyboardKey.numpad0, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad0, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad1, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad1, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad2, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad2, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad3, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad3, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad4, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad4, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad5, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad5, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad6, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad6, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad7, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad7, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad8, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad8, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpad9, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpad9, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadDivide, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpadDivide, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadMultiply, meta: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadMultiply, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadSubtract, meta: true):
      KeyboardIntent(
          LogicalKeyboardKey.numpadSubtract, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadAdd, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpadAdd, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadDecimal, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpadDecimal, LogicalKeyboardKey.meta),
  SingleActivator(LogicalKeyboardKey.numpadEnter, meta: true):
      KeyboardIntent(LogicalKeyboardKey.numpadEnter, LogicalKeyboardKey.meta),

  // alt
  SingleActivator(LogicalKeyboardKey.numpad0, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad0, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad1, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad1, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad2, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad2, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad3, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad3, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad4, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad4, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad5, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad5, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad6, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad6, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad7, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad7, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad8, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad8, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpad9, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpad9, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadDivide, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadDivide, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadMultiply, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadMultiply, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadSubtract, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadSubtract, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadAdd, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadAdd, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadDecimal, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadDecimal, LogicalKeyboardKey.alt),
  SingleActivator(LogicalKeyboardKey.numpadEnter, alt: true):
      KeyboardIntent(LogicalKeyboardKey.numpadEnter, LogicalKeyboardKey.alt),
};

const arrowKeysIntentMap = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.arrowUp): KeyboardIntent(LogicalKeyboardKey.arrowUp),
  SingleActivator(LogicalKeyboardKey.arrowDown): KeyboardIntent(LogicalKeyboardKey.arrowDown),
};

final numpadKeyLabels = {
  LogicalKeyboardKey.numpad0: '0',
  LogicalKeyboardKey.numpad1: '1',
  LogicalKeyboardKey.numpad2: '2',
  LogicalKeyboardKey.numpad3: '3',
  LogicalKeyboardKey.numpad4: '4',
  LogicalKeyboardKey.numpad5: '5',
  LogicalKeyboardKey.numpad6: '6',
  LogicalKeyboardKey.numpad7: '7',
  LogicalKeyboardKey.numpad8: '8',
  LogicalKeyboardKey.numpad9: '9',
  LogicalKeyboardKey.numpadEnter: 'Enter',
  LogicalKeyboardKey.numpadDecimal: '.',
  LogicalKeyboardKey.numpadAdd: '+',
  LogicalKeyboardKey.numpadSubtract: '-',
  LogicalKeyboardKey.numpadMultiply: '*',
  LogicalKeyboardKey.numpadDivide: '/',
  LogicalKeyboardKey.numpadEqual: '=',
  LogicalKeyboardKey.meta: 'Cmd',
  LogicalKeyboardKey.control: 'Ctrl',
  LogicalKeyboardKey.shift: 'Shift',
  LogicalKeyboardKey.alt: 'Alt',
};

