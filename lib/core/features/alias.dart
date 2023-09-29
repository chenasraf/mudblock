import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';

class Alias extends Automation {
  Alias({
    super.enabled = true,
    required super.id,
    required super.pattern,
    required super.action,
    super.isRegex = false,
    super.isCaseSensitive = false,
    super.isRemovedFromBuffer = false,
    super.autoDisable = false,
    super.invokeCount = 0,
  });

  factory Alias.empty() => Alias(
        id: uuid(),
        pattern: '',
        enabled: true,
        isRegex: false,
        isCaseSensitive: false,
        isRemovedFromBuffer: false,
        autoDisable: false,
        invokeCount: 0,
        action: MUDAction.empty(),
      );

  factory Alias.fromJson(Map<String, dynamic> json) => Alias(
        id: json['id'],
        pattern: json['pattern'],
        enabled: json['enabled'],
        isRegex: json['isRegex'],
        isCaseSensitive: json['isCaseSensitive'],
        isRemovedFromBuffer: json['isRemovedFromBuffer'],
        autoDisable: json['autoDisable'],
        invokeCount: json['invokeCount'],
        action: MUDAction.fromJson(json['action']),
      );

  @override
  Alias copyWith({
    String? id,
    String? pattern,
    bool? enabled,
    bool? isRegex,
    bool? isCaseSensitive,
    bool? isRemovedFromBuffer,
    bool? autoDisable,
    int? invokeCount = 0,
    MUDAction? action,
  }) =>
      Alias(
        id: id ?? this.id,
        pattern: pattern ?? this.pattern,
        enabled: enabled ?? this.enabled,
        isRegex: isRegex ?? this.isRegex,
        isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
        isRemovedFromBuffer: isRemovedFromBuffer ?? this.isRemovedFromBuffer,
        autoDisable: autoDisable ?? this.autoDisable,
        invokeCount: invokeCount ?? this.invokeCount,
        action: action ?? this.action,
      );
}

