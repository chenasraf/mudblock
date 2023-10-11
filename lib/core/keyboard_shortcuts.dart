import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'store.dart';

class KeyboardIntent extends Intent {
  const KeyboardIntent(this.key, this.context);

  final NumpadKey key;
  final BuildContext context;
}

class KeyboardAction extends Action<KeyboardIntent> with GameStoreMixin {
  @override
  void invoke(covariant KeyboardIntent intent) {
    final store = storeOf(intent.context);
    store.onShortcut(intent.key, intent.context);
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
    this.numpad0 = '',
    this.numpad1 = '',
    this.numpad2 = '',
    this.numpad3 = '',
    this.numpad4 = '',
    this.numpad5 = '',
    this.numpad6 = '',
    this.numpad7 = '',
    this.numpad8 = '',
    this.numpad9 = '',
    this.numpadEnter = '',
    this.numpadDecimal = '',
    this.numpadAdd = '',
    this.numpadSubtract = '',
    this.numpadMultiply = '',
    this.numpadDivide = '',
    this.numpadEqual = '',
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

Map<ShortcutActivator, Intent> numpadKeysIntentMap(BuildContext context) =>
    <ShortcutActivator, Intent>{
      // SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.numpad0):
          KeyboardIntent(NumpadKey.numpad0, context),
      const SingleActivator(LogicalKeyboardKey.numpad1):
          KeyboardIntent(NumpadKey.numpad1, context),
      const SingleActivator(LogicalKeyboardKey.numpad2):
          KeyboardIntent(NumpadKey.numpad2, context),
      const SingleActivator(LogicalKeyboardKey.numpad3):
          KeyboardIntent(NumpadKey.numpad3, context),
      const SingleActivator(LogicalKeyboardKey.numpad4):
          KeyboardIntent(NumpadKey.numpad4, context),
      const SingleActivator(LogicalKeyboardKey.numpad5):
          KeyboardIntent(NumpadKey.numpad5, context),
      const SingleActivator(LogicalKeyboardKey.numpad6):
          KeyboardIntent(NumpadKey.numpad6, context),
      const SingleActivator(LogicalKeyboardKey.numpad7):
          KeyboardIntent(NumpadKey.numpad7, context),
      const SingleActivator(LogicalKeyboardKey.numpad8):
          KeyboardIntent(NumpadKey.numpad8, context),
      const SingleActivator(LogicalKeyboardKey.numpad9):
          KeyboardIntent(NumpadKey.numpad9, context),
      const SingleActivator(LogicalKeyboardKey.numpadDivide):
          KeyboardIntent(NumpadKey.numpadDivide, context),
      const SingleActivator(LogicalKeyboardKey.numpadMultiply):
          KeyboardIntent(NumpadKey.numpadMultiply, context),
      const SingleActivator(LogicalKeyboardKey.numpadSubtract):
          KeyboardIntent(NumpadKey.numpadSubtract, context),
      const SingleActivator(LogicalKeyboardKey.numpadAdd):
          KeyboardIntent(NumpadKey.numpadAdd, context),
      const SingleActivator(LogicalKeyboardKey.numpadDecimal):
          KeyboardIntent(NumpadKey.numpadDecimal, context),
      const SingleActivator(LogicalKeyboardKey.numpadEnter):
          KeyboardIntent(NumpadKey.numpadEnter, context),
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

