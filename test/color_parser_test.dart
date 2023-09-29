import 'package:flutter_test/flutter_test.dart';
import 'package:mudblock/core/consts.dart';
import 'package:mudblock/core/parser/parser.dart';

const inputs = [
  '$esc[32mYou are standing in a small clearing.$esc[0m',
  'You are standing in a small clearing.',
  '$esc[0m$esc[1m$esc[0m$esc[1m$esc[31mWelcome to SimpleMUD$esc[0m$esc[1m$esc[0m',
  '$esc[0m$esc[37m$esc[0m$esc[37m$esc[1m[$esc[0m$esc[37m$esc[1m$esc[32m10$esc[0m$esc[37m$esc[1m/10]$esc[0m$esc[37m$esc[0m'
];

void main() {
  group('ColorParser', () {
    test('colored output 1', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken('You are standing in a small clearing.', 32, 0),
        ColorToken.empty(),
      ]);
    });
  });
}
