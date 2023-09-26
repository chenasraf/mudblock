import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';

class Trigger extends Automation {
  Trigger({
    super.enabled = true,
    required super.id,
    required super.pattern,
    required super.action,
    super.isRegex = false,
    super.isCaseSensitive = false,
    super.isRemovedFromBuffer = false,
    super.isTemporary = false,
    super.invokeCount = 0,
  });

  factory Trigger.empty() => Trigger(
        id: uuid(),
        pattern: '',
        enabled: true,
        isRegex: false,
        isCaseSensitive: false,
        isRemovedFromBuffer: false,
        isTemporary: false,
        invokeCount: 0,
        action: MUDAction.empty(),
      );

  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
        id: json['id'],
        pattern: json['pattern'],
        enabled: json['enabled'],
        isRegex: json['isRegex'],
        isCaseSensitive: json['isCaseSensitive'],
        isRemovedFromBuffer: json['isRemovedFromBuffer'],
        isTemporary: json['isTemporary'],
        invokeCount: json['invokeCount'],
        action: MUDAction.fromJson(json['action']),
      );

  @override
  Trigger copyWith({
    String? id,
    String? pattern,
    bool? enabled,
    bool? isRegex,
    bool? isCaseSensitive,
    bool? isRemovedFromBuffer,
    bool? isTemporary,
    int? invokeCount = 0,
    MUDAction? action,
  }) =>
      Trigger(
        id: id ?? this.id,
        pattern: pattern ?? this.pattern,
        enabled: enabled ?? this.enabled,
        isRegex: isRegex ?? this.isRegex,
        isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
        isRemovedFromBuffer: isRemovedFromBuffer ?? this.isRemovedFromBuffer,
        isTemporary: isTemporary ?? this.isTemporary,
        invokeCount: invokeCount ?? this.invokeCount,
        action: action ?? this.action,
      );
}

