class BuiltinCommand {
  static help() {
    const sep =
        '--------------------------------------------------------------------------------';
    final year = DateTime.now().year;
    return '''
$sep
Mudblock - Help
$sep

Mudblock is a cross-platform MUD client.
See more information at https://github.com/chenasraf/mudblock

$sep
Developed by Chen Asraf
Copyright © $year - All Rights Reserved
$sep
''';
  }
}

