import 'package:flutter/widgets.dart';

import 'action.dart';

class Trigger {
  String id;
  String pattern;
  bool enabled;
  bool isRegex;
  bool isCaseSensitive;
  // bool isMultiLine;
  bool isRemovedFromBuffer;
  bool isTemporary;
  int invokeCount = 0;
  MUDAction action;

  Trigger({
    this.enabled = true,
    required this.id,
    required this.pattern,
    required this.action,
    this.isRegex = false,
    this.isCaseSensitive = false,
    // required this.isMultiLine,
    this.isRemovedFromBuffer = false,
    this.isTemporary = false,
  });

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
      final regex = RegExp(pattern, caseSensitive: isCaseSensitive, unicode: true);
      final rMatches = regex.allMatches(str);
      final matches = <String>[];
      for (var i = 0; i < rMatches.length; i++) {
        debugPrint('${rMatches.elementAt(i).groupCount} matches in ${rMatches.elementAt(i).group(0)}');
        for (var j = 0; j < rMatches.elementAt(i).groupCount + 1; j++) {
          if (rMatches.elementAt(i).group(j) != null) {
            debugPrint('Trigger.allMatches $i,$j: ${rMatches.elementAt(i).group(j)}');
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
}

