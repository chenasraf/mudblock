import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';

class KeyboardIntent extends Intent {
  const KeyboardIntent(this.key);

  final NumpadKey key;
}

class KeyboardAction extends ContextAction<KeyboardIntent> with GameStoreMixin {
  @override
  void invoke(covariant KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) return;
    final store = storeOf(context);
    store.onShortcut(intent.key, context);
  }

  @override
  bool isEnabled(KeyboardIntent intent, [BuildContext? context]) {
    if (context == null) return false;
    final store = storeOf(context);
    if (store.keyboardShortcuts.get(intent.key).isEmpty) return false;
    return super.isEnabled(intent, context);
  }
}

enum NumpadKey {
  numpad0,
  numpad1,
  numpad2,
  numpad3,
  numpad4,
  numpad5,
  numpad6,
  numpad7,
  numpad8,
  numpad9,
  numpadEnter,
  numpadDecimal,
  numpadAdd,
  numpadSubtract,
  numpadMultiply,
  numpadDivide,
  numpadEqual,
}

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

  String get(NumpadKey key) =>
      {
        NumpadKey.numpad0: numpad0,
        NumpadKey.numpad1: numpad1,
        NumpadKey.numpad2: numpad2,
        NumpadKey.numpad3: numpad3,
        NumpadKey.numpad4: numpad4,
        NumpadKey.numpad5: numpad5,
        NumpadKey.numpad6: numpad6,
        NumpadKey.numpad7: numpad7,
        NumpadKey.numpad8: numpad8,
        NumpadKey.numpad9: numpad9,
        NumpadKey.numpadEnter: numpadEnter,
        NumpadKey.numpadDecimal: numpadDecimal,
        NumpadKey.numpadAdd: numpadAdd,
        NumpadKey.numpadSubtract: numpadSubtract,
        NumpadKey.numpadMultiply: numpadMultiply,
        NumpadKey.numpadDivide: numpadDivide,
        NumpadKey.numpadEqual: numpadEqual,
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

  KeyboardShortcuts copyWithMap(Map<NumpadKey, String> map) => copyWith(
        numpad0: map[NumpadKey.numpad0],
        numpad1: map[NumpadKey.numpad1],
        numpad2: map[NumpadKey.numpad2],
        numpad3: map[NumpadKey.numpad3],
        numpad4: map[NumpadKey.numpad4],
        numpad5: map[NumpadKey.numpad5],
        numpad6: map[NumpadKey.numpad6],
        numpad7: map[NumpadKey.numpad7],
        numpad8: map[NumpadKey.numpad8],
        numpad9: map[NumpadKey.numpad9],
        numpadEnter: map[NumpadKey.numpadEnter],
        numpadDecimal: map[NumpadKey.numpadDecimal],
        numpadAdd: map[NumpadKey.numpadAdd],
        numpadSubtract: map[NumpadKey.numpadSubtract],
        numpadMultiply: map[NumpadKey.numpadMultiply],
        numpadDivide: map[NumpadKey.numpadDivide],
        numpadEqual: map[NumpadKey.numpadEqual],
      );
}

const numpadKeysIntentMap = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.numpad0):
      KeyboardIntent(NumpadKey.numpad0),
  SingleActivator(LogicalKeyboardKey.numpad1):
      KeyboardIntent(NumpadKey.numpad1),
  SingleActivator(LogicalKeyboardKey.numpad2):
      KeyboardIntent(NumpadKey.numpad2),
  SingleActivator(LogicalKeyboardKey.numpad3):
      KeyboardIntent(NumpadKey.numpad3),
  SingleActivator(LogicalKeyboardKey.numpad4):
      KeyboardIntent(NumpadKey.numpad4),
  SingleActivator(LogicalKeyboardKey.numpad5):
      KeyboardIntent(NumpadKey.numpad5),
  SingleActivator(LogicalKeyboardKey.numpad6):
      KeyboardIntent(NumpadKey.numpad6),
  SingleActivator(LogicalKeyboardKey.numpad7):
      KeyboardIntent(NumpadKey.numpad7),
  SingleActivator(LogicalKeyboardKey.numpad8):
      KeyboardIntent(NumpadKey.numpad8),
  SingleActivator(LogicalKeyboardKey.numpad9):
      KeyboardIntent(NumpadKey.numpad9),
  SingleActivator(LogicalKeyboardKey.numpadDivide):
      KeyboardIntent(NumpadKey.numpadDivide),
  SingleActivator(LogicalKeyboardKey.numpadMultiply):
      KeyboardIntent(NumpadKey.numpadMultiply),
  SingleActivator(LogicalKeyboardKey.numpadSubtract):
      KeyboardIntent(NumpadKey.numpadSubtract),
  SingleActivator(LogicalKeyboardKey.numpadAdd):
      KeyboardIntent(NumpadKey.numpadAdd),
  SingleActivator(LogicalKeyboardKey.numpadDecimal):
      KeyboardIntent(NumpadKey.numpadDecimal),
  SingleActivator(LogicalKeyboardKey.numpadEnter):
      KeyboardIntent(NumpadKey.numpadEnter),
};

final numpadKeyLabels = {
  NumpadKey.numpad0: '0',
  NumpadKey.numpad1: '1',
  NumpadKey.numpad2: '2',
  NumpadKey.numpad3: '3',
  NumpadKey.numpad4: '4',
  NumpadKey.numpad5: '5',
  NumpadKey.numpad6: '6',
  NumpadKey.numpad7: '7',
  NumpadKey.numpad8: '8',
  NumpadKey.numpad9: '9',
  NumpadKey.numpadEnter: 'Enter',
  NumpadKey.numpadDecimal: '.',
  NumpadKey.numpadAdd: '+',
  NumpadKey.numpadSubtract: '-',
  NumpadKey.numpadMultiply: '*',
  NumpadKey.numpadDivide: '/',
  NumpadKey.numpadEqual: '=',
};

