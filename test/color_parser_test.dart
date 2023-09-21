import 'package:flutter_test/flutter_test.dart';
import 'package:mudblock/core/color_parser.dart';
import 'package:mudblock/core/consts.dart';

void main() {
  test('Tokenizer', () {
    const input1 = '$esc[32mYou are standing in a small clearing.$esc[0m';
    final reader = StringReader(input1);
    final output = Tokenizer(reader).tokenize();
    expect(output, [
      TokenValue.esc,
      TokenValue.colorStart,
      TokenValue.literal('32'),
      TokenValue.colorTerm,
      TokenValue.literal('You are standing in a small clearing.'),
      TokenValue.esc,
      TokenValue.colorStart,
      TokenValue.literal('0'),
      TokenValue.colorTerm,
    ]);
  });

  test('Lexer', () {
    const input1 = '$esc[32mYou are standing in a small clearing.$esc[0m';
    final reader = StringReader(input1);
    final tokenizer = Tokenizer(reader);
    final output = Lexer(tokenizer).lex();
    expect(output, [
      LexerValue('You are standing in a small clearing.', 32, 0),
      LexerValue('', 0, 0),
    ]);
  });
}

