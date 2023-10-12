import 'package:flutter/material.dart';

import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';

class Trigger extends Automation {
  Trigger({
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

  static const IconData iconData = Icons.lightbulb;

  factory Trigger.empty() => Trigger(
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

  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
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
  Trigger copyWith({
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
      Trigger(
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
