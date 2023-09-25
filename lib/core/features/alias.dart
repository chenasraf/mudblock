import 'package:flutter/widgets.dart';

import '../string_utils.dart';
import 'action.dart';

class Alias {
  String id;
  String pattern;
  bool enabled;
  bool isRegex;
  bool isCaseSensitive;
  bool isRemovedFromBuffer;
  bool isTemporary;
  int invokeCount;
  MUDAction action;

  Alias({
    this.enabled = true,
    required this.id,
    required this.pattern,
    required this.action,
    this.isRegex = false,
    this.isCaseSensitive = false,
    this.isRemovedFromBuffer = false,
    this.isTemporary = false,
    this.invokeCount = 0,
  });

  factory Alias.empty() => Alias(
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

  factory Alias.fromJson(Map<String, dynamic> json) => Alias(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'pattern': pattern,
        'enabled': enabled,
        'isRegex': isRegex,
        'isCaseSensitive': isCaseSensitive,
        'isRemovedFromBuffer': isRemovedFromBuffer,
        'isTemporary': isTemporary,
        'invokeCount': invokeCount,
        'action': action.toJson(),
      };

  bool matches(String line) {
    if (isRegex) {
      final regex = RegExp(pattern, caseSensitive: isCaseSensitive);
      return regex.hasMatch(line);
    } else {
      if (isCaseSensitive) {
        return line.toLowerCase().contains(pattern.toLowerCase());
      }
      return line.contains(pattern);
    }
  }

  void invokeEffect(BuildContext context, String line) {
    invokeCount++;
    action.invoke(context, allMatches(line));
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

  Alias copyWith({
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
      Alias(
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

