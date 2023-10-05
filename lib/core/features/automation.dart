import 'package:meta/meta.dart';

import '../store.dart';
import '../string_utils.dart';
import 'action.dart';

class Automation {
  String id;
  String pattern;
  bool enabled;
  bool isRegex;
  bool isCaseSensitive;
  bool isRemovedFromBuffer;
  bool autoDisable;
  int invokeCount;
  String group;

  /// This is used to temporarily disable an automation after using it once when it has autoDisable set to true.
  bool tempDisabled = false;
  MUDAction action;

  Automation({
    this.enabled = true,
    required this.id,
    required this.pattern,
    required this.action,
    this.isRegex = false,
    this.isCaseSensitive = false,
    this.isRemovedFromBuffer = false,
    this.autoDisable = false,
    this.invokeCount = 0,
    this.group = '',
  });

  /// is both enabled (globally by the user) and not temporarily disabled (by the automation itself)
  bool get isAvailable => enabled && !tempDisabled;

  factory Automation.empty() => Automation(
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

  factory Automation.fromJson(Map<String, dynamic> json) => Automation(
        id: json['id'],
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'pattern': pattern,
        'enabled': enabled,
        'isRegex': isRegex,
        'isCaseSensitive': isCaseSensitive,
        'isRemovedFromBuffer': isRemovedFromBuffer,
        'autoDisable': autoDisable,
        'invokeCount': invokeCount,
        'action': action.toJson(),
        'group': group,
      };

  bool matches(String line) {
    return actualRegex.hasMatch(line);
  }

  String get actualPattern => isRegex ? pattern : _strToRegExp(pattern).pattern;
  RegExp get actualRegex => isRegex ? RegExp(pattern, caseSensitive: isCaseSensitive) : _strToRegExp(pattern);

  RegExp _strToRegExp(String pattern) {
    final updatedPattern = pattern
        .replaceAll(r'\', r'\')
        .replaceAll(r'(', r'\(')
        .replaceAll(r')', r'\)')
        .replaceAll(r'[', r'\[')
        .replaceAll(r']', r'\]')
        .replaceAll(r'/', r'\/')
        .replaceAll('*', '(.*?)');
    final regex = RegExp("^$updatedPattern\$", caseSensitive: isCaseSensitive);
    return regex;
  }

  void invokeEffect(GameStore store, String line) {
    invokeCount++;
    action.invoke(store, this, allMatches(line));
  }

  List<String> allMatches(String str) {
    if (!matches(str)) {
      return [];
    }
    final regex = actualRegex;
    final foundMatches = regex.allMatches(str);
    final results = <String>[];
    for (var i = 0; i < foundMatches.length; i++) {
      for (var j = 0; j < foundMatches.elementAt(i).groupCount + 1; j++) {
        if (foundMatches.elementAt(i).group(j) != null) {
          results.add(foundMatches.elementAt(i).group(j)!);
        }
      }
    }
    return results;
  }

  @mustBeOverridden
  Automation copyWith({
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
      Automation(
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

