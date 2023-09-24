import 'package:flutter/widgets.dart';

import 'action.dart';

class Trigger {
  String id;
  String pattern;
  bool isRegex;
  bool isCaseSensitive;
  // bool isMultiLine;
  bool isRemovedFromBuffer;
  bool isTemporary;
  int invokeCount = 0;
  MUDAction action;

  Trigger({
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

  List<String> allMatches(str) {
    if (!matches(str)) {
      return [];
    }
    if (isRegex) {
      final regex = RegExp(pattern, caseSensitive: isCaseSensitive);
      debugPrint('allMatches: ${regex.allMatches(str).map((m) => m.group(1)!).toList()}');
      return regex.allMatches(str).map((m) => m.group(0)!).toList();
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

