import 'package:flutter_test/flutter_test.dart';
import 'package:mudblock/core/color_parser.dart';
import 'package:mudblock/core/consts.dart';

void main() {
  group('Tokenizer', () {
    test('colored output', () {
      const input = '$esc[32mYou are standing in a small clearing.$esc[0m';
      final reader = StringReader(input);
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

    test('non colored output', () {
      const input = 'You are standing in a small clearing.';
      final reader = StringReader(input);
      final output = Tokenizer(reader).tokenize();
      expect(output, [
        TokenValue.literal('You are standing in a small clearing.'),
      ]);
    });
  });

  group('Lexer', () {
    test('colored output', () {
      const input = '$esc[32mYou are standing in a small clearing.$esc[0m';
      final reader = StringReader(input);
      final tokenizer = Tokenizer(reader);
      final output = Lexer(tokenizer).lex();
      expect(output, [
        LexerValue('You are standing in a small clearing.', 32, 0),
        LexerValue('', 0, 0),
      ]);
    });

    test('colored output 2', () {
      const output = '$esc[0m$esc[1m$esc[0m$esc[1m$esc[31mWelcome to SimpleMUD$esc[0m$esc[1m$esc[0m';
      final reader = StringReader(output);
      final tokenizer = Tokenizer(reader);
      final result = Lexer(tokenizer).lex();
      expect(result, [
        LexerValue('Welcome to SimpleMUD', 31, 0),
        LexerValue('', 0, 0),
      ]);
    });

    test('colored output 3', () {
      const output =
          '$esc[0m$esc[37m$esc[0m$esc[37m$esc[1m[$esc[0m$esc[37m$esc[1m$esc[32m10$esc[0m$esc[37m$esc[1m/10]$esc[0m$esc[37m$esc[0m';
      final reader = StringReader(output);
      final tokenizer = Tokenizer(reader);
      final result = Lexer(tokenizer).lex();
      expect(result, [
        LexerValue('[10/10]', 32, 0),
        LexerValue('', 0, 0),
      ]);
    });

    test('color reset', () {
      const input = '$esc[mYou are standing in a small clearing.';
      final reader = StringReader(input);
      final tokenizer = Tokenizer(reader);
      final output = Lexer(tokenizer).lex();
      expect(output, [
        LexerValue('You are standing in a small clearing.', 0, 0),
      ]);
    });

    test('non colored output', () {
      const input = 'You are standing in a small clearing.';
      final reader = StringReader(input);
      final tokenizer = Tokenizer(reader);
      final output = Lexer(tokenizer).lex();
      expect(output, [
        LexerValue('You are standing in a small clearing.', 0, 0),
      ]);
    });
  });
}

