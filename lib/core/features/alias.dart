import 'package:flutter/material.dart';

import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';
import 'builtin_command.dart';

class Alias extends Automation {
  Alias({
    super.enabled = true,
    required super.id,
    required super.pattern,
    required super.action,
    super.label = '',
    super.isRegex = false,
    super.isCaseSensitive = false,
    super.isRemovedFromBuffer = false,
    super.autoDisable = false,
    super.invokeCount = 0,
    super.group = '',
  });

  static const IconData iconData = Icons.text_fields;

  factory Alias.empty() => Alias(
        id: uuid(),
        label: '',
        pattern: '',
        enabled: true,
        isRegex: false,
        isCaseSensitive: false,
        isRemovedFromBuffer: false,
        autoDisable: false,
        invokeCount: 0,
        action: MUDAction.empty(),
        group: '',
      );

  factory Alias.fromJson(Map<String, dynamic> json) => Alias(
        id: json['id'],
        label: json['label'] ?? '',
        pattern: json['pattern'],
        enabled: json['enabled'],
        isRegex: json['isRegex'],
        isCaseSensitive: json['isCaseSensitive'],
        isRemovedFromBuffer: json['isRemovedFromBuffer'],
        autoDisable: json['autoDisable'],
        invokeCount: json['invokeCount'],
        action: MUDAction.fromJson(json['action']),
        group: json['group'] ?? '',
      );

  @override
  Alias copyWith({
    String? id,
    String? label,
    String? pattern,
    bool? enabled,
    bool? isRegex,
    bool? isCaseSensitive,
    bool? isRemovedFromBuffer,
    bool? autoDisable,
    int? invokeCount = 0,
    MUDAction? action,
    String? group,
  }) =>
      Alias(
        id: id ?? this.id,
        label: label ?? this.label,
        pattern: pattern ?? this.pattern,
        enabled: enabled ?? this.enabled,
        isRegex: isRegex ?? this.isRegex,
        isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
        isRemovedFromBuffer: isRemovedFromBuffer ?? this.isRemovedFromBuffer,
        autoDisable: autoDisable ?? this.autoDisable,
        invokeCount: invokeCount ?? this.invokeCount,
        action: action ?? this.action,
        group: group ?? this.group,
      );
}

String _key(String str) => 'builtin-alias-$str';

final builtInAliases = <Alias>[
  Alias(
    id: _key('lua-long'),
    pattern: 'lua *',
    action: MUDAction('%1', target: MUDActionTarget.script),
  ),
  Alias(
    id: _key('lua-short'),
    pattern: r'[\\]{3}(.*)',
    isRegex: true,
    action: MUDAction('%1', target: MUDActionTarget.script),
  ),
  Alias(
    id: _key('help'),
    pattern: 'mudhelp',
    action: NativeMUDAction(
      (store, matches) {
        store.echo(BuiltinCommand.help());
      },
    ),
  ),
];

