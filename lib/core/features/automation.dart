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
  });

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
      };

  bool matches(String line) {
    if (isRegex) {
      final regex = RegExp(pattern, caseSensitive: isCaseSensitive);
      return regex.hasMatch(line);
    } else {
      final updatedPattern = pattern.replaceAll('*', '(.*?)');
      final regex =
          RegExp("^$updatedPattern\$", caseSensitive: isCaseSensitive);
      return regex.hasMatch(line);
    }
  }

  void invokeEffect(GameStore store, String line) {
    invokeCount++;
    action.invoke(store, allMatches(line));
  }

  List<String> allMatches(String str) {
    if (!matches(str)) {
      return [];
    }
    if (isRegex) {
      final regex =
          RegExp(pattern, caseSensitive: isCaseSensitive, unicode: true);
      final rMatches = regex.allMatches(str);
      final matches = <String>[];
      for (var i = 0; i < rMatches.length; i++) {
        for (var j = 0; j < rMatches.elementAt(i).groupCount + 1; j++) {
          if (rMatches.elementAt(i).group(j) != null) {
            matches.add(rMatches.elementAt(i).group(j)!);
          }
        }
      }
      return matches;
    } else {
      final input = isCaseSensitive ? str.toLowerCase() : str;
      final compare = isCaseSensitive ? pattern.toLowerCase() : pattern;
      final matches = <String>[str];
      for (var i = 0; i < input.length; i++) {
        final index = input.indexOf(compare, i);
        if (index == -1) {
          break;
        }
        matches.add(str.substring(index, index + compare.length));
        i = index + compare.length;
      }
      return matches;
    }
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

