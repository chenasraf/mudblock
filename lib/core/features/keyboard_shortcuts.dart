import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';

class KeyboardIntent extends Intent {
  const KeyboardIntent(this.key);

  final LogicalKeyboardKey key;
}

class KeyboardAction extends ContextAction<KeyboardIntent> with GameStoreMixin {
  @override
  void invoke(covariant KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) {
      return;
    }
    final store = storeOf(context);
    if (store.currentProfile.keyboardShortcuts.get(intent.key).isNotEmpty) {
      store.onShortcut(intent.key, context);
    } else {
      store.selectInput();
      store.setInput(
        store.input.text + intent.key.keyLabel.replaceAll('Numpad ', ''),
      );
    }
  }

  @override
  bool isEnabled(KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) {
      return false;
    }
    final store = storeOf(context);
    if (store.currentProfile.keyboardShortcuts.get(intent.key).isEmpty) {
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

class KeyboardShortcuts {
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

  KeyboardShortcuts({
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

  factory KeyboardShortcuts.empty() => KeyboardShortcuts(
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

  factory KeyboardShortcuts.fromJson(Map<String, dynamic> json) {
    return KeyboardShortcuts(
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

  KeyboardShortcuts copyWith({
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
      KeyboardShortcuts(
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

  KeyboardShortcuts copyWithMap(Map<LogicalKeyboardKey, String> map) =>
      copyWith(
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
};

