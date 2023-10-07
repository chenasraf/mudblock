// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  String flutterSdk;
  try {
    flutterSdk = Process.runSync('which', ['flutter'])
        .stdout
        .toString()
        .trim()
        .split('/bin')[0];
  } catch (e) {
    print("Couldn't find flutter sdk");
    exit(1);
  }

  final inputFile =
      File("$flutterSdk/packages/flutter/lib/src/material/icons.dart");
  final output = File('lib/core/icon_list.g.dart');

  final icons = <String, Set<String>>{};

  final lines = await inputFile.readAsLines();
  for (final line in lines) {
    try {
      if (line.contains('static const IconData')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        final name = parts[3];
        final code = parts[5].split('(')[1].split(',')[0];
        final font = parts[7].split("'")[1];
        icons[name] = {code, font};
        print('Found icon: $name ($code, $font)');
      }
    } catch (e, stack) {
      print('Error parsing line: $line');
      print(e);
      print(stack);
      print(
          'parts: ${line.split(RegExp(r'\s+')).map((e) => '"$e"').join(', ')}');
      break;
    }
  }

  final iconListLines = icons.entries.map((e) {
    final name = e.key;
    final code = e.value.first;
    final font = e.value.last;
    return "'$name': const IconData($code, fontFamily: '$font'),";
  });

  print('Found ${icons.length} icons');
  print('Writing to ${output.path}');

  var template = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
final iconList = {
${iconListLines.join('\n')}
};
''';

  output.writeAsStringSync(template);

  print('Running flutter format');

  Process.runSync('dart', ['format', 'lib/core/icon_list.g.dart']);

  print('Done');
}
