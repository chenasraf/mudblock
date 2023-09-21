import 'package:flutter/foundation.dart';

import 'consts.dart' as consts;

enum Token {
  esc,
  colorStart,
  colorTerm,
  colorSeparator,
  literal,
}

class TokenValue {
  final Token token;
  final String raw;

  const TokenValue(this.token, this.raw);

  static const esc = TokenValue(Token.esc, consts.esc);
  static const colorStart = TokenValue(Token.colorStart, '[');
  static const colorSeparator = TokenValue(Token.colorSeparator, ';');
  static const colorTerm = TokenValue(Token.colorTerm, 'm');
  static const empty = TokenValue(Token.literal, '');

  TokenValue.literal(String raw) : this(Token.literal, raw);

  @override
  int get hashCode => raw.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenValue && runtimeType == other.runtimeType && token == other.token && raw == other.raw;

  @override
  String toString() => token != Token.esc ? 'TokenValue($token, $raw)' : 'TokenValue($token)';
}

class LexerValue {
  String text;
  int fgColor;
  int bgColor;

  LexerValue(this.text, this.fgColor, this.bgColor);

  @override
  int get hashCode => text.hashCode ^ fgColor.hashCode ^ bgColor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexerValue &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          fgColor == other.fgColor &&
          bgColor == other.bgColor;

  @override
  String toString() => 'LexerValue($text, $fgColor, $bgColor)';
}

abstract class IReader<T> {
  T read();
  T peek();
  int get index;
  bool get isDone;
}

abstract class ITokenizer {
  List<TokenValue> tokenize();
}

abstract class ILexer {
  List<LexerValue> lex();
}

class StringReader implements IReader<String> {
  final String input;

  @override
  int index = 0;

  StringReader(this.input);

  @override
  bool get isDone => index >= input.length;

  @override
  String peek() {
    if (isDone) {
      throw Exception('Cannot peek at end of input');
    }
    return input[index];
  }

  @override
  String read() {
    if (isDone) {
      throw Exception('Cannot read at end of input');
    }
    return input[index++];
  }
}

class Tokenizer<T> implements ITokenizer {
  final IReader<T> reader;
  bool insideColor = false;

  Tokenizer(this.reader);

  @override
  List<TokenValue> tokenize() {
    final tokens = <TokenValue>[];
    while (!reader.isDone) {
      final char = reader.read();
      final token = getToken(char.toString());
      if (token.token == Token.colorStart) {
        insideColor = true;
      } else if (token.token == Token.colorTerm) {
        insideColor = false;
      }
      var last = tokens.lastOrNull;
      if (token.token == Token.literal && last != null && last.token == Token.literal) {
        last = TokenValue(Token.literal, last.raw + char.toString());
        tokens.removeLast();
        tokens.add(last);
        continue;
      }
      tokens.add(token);
    }
    return tokens;
  }

  TokenValue getToken(String char) {
    switch (char) {
      case consts.esc:
        return TokenValue.esc;
      case ';':
        return insideColor ? TokenValue.colorSeparator : TokenValue.literal(char.toString());
      case 'm':
        return insideColor ? TokenValue.colorTerm : TokenValue.literal(char.toString());
      case '[':
        return !insideColor ? TokenValue.colorStart : TokenValue.literal(char.toString());
    }
    return TokenValue.literal(char.toString());
  }
}

class Lexer implements ILexer, IReader {
  final ITokenizer tokenizer;
  LexerValue? cur;
  bool insideColor = false;
  bool insideBgColor = false;
  LexerValue? temp;
  // bool escapeNext = false;
  List<TokenValue> tokens = [];

  Lexer(this.tokenizer);

  @override
  List<LexerValue> lex() {
    tokens = tokenizer.tokenize();
    final lexed = <LexerValue>[];

    while (!isDone) {
      final token = read();
      debugPrint("lex token: $token");
      var cur = getToken(token);
      if (cur == null) {
        continue;
      }
      debugPrint("lex adding: $cur");
      lexed.add(cur);
    }
    return lexed;
  }

  LexerValue? getToken(TokenValue token) {
    debugPrint('getToken: $token');
    if (temp != null) {
      var ret = temp;
      temp = null;
      return ret;
    }
    switch (token.token) {
      case Token.esc:
        temp = LexerValue('', 0, 0);
        // escapeNext = true;
        return getEscapedToken(read());
      default:
        if (temp != null) {
          temp!.text += token.raw;
          return getEscapedToken(read());
        }
        return null;
    }
  }

  LexerValue? getEscapedToken(TokenValue? token) {
    debugPrint('getEscapedToken: $token, insideColor: $insideColor, insideBgColor: $insideBgColor');
    debugPrint('getEscapedToken temp: $temp');
    if (token == null) {
      // escapeNext = false;
      return null;
    }
    switch (token.token) {
      case Token.colorStart:
        insideColor = true;
        var next = getEscapedToken(read());
        if (next == null) {
          return temp;
        }
        return next;
      case Token.colorSeparator:
        insideBgColor = true;
        var next = getEscapedToken(read());
        if (next == null) {
          return temp;
        }
        return next;
      case Token.colorTerm:
        insideColor = false;
        insideBgColor = false;
        // escapeNext = false;
        debugPrint('colorTerm, isDone: $isDone, temp: $temp');
        if (isDone) {
          return temp;
        }
        var next = getEscapedToken(read());
        if (next == null) {
          return temp;
        }
        return next;
      case Token.literal:
      default:
        if (insideColor) {
          debugPrint('insideColor: $insideColor, insideBgColor: $insideBgColor, raw: ${token.raw}');
          if (insideBgColor) {
            temp!.bgColor = int.parse(token.raw);
          } else {
            debugPrint('Setting fgColor: ${token.raw}');
            temp!.fgColor = int.parse(token.raw);
          }
          if (isDone) {
            debugPrint('isDone, returning temp: $temp');
            return temp;
          }
          debugPrint('Not isDone, reading next');
          return getEscapedToken(read());
        } else {
          // escapeNext = false;
          temp!.text += token.raw;
          if (isDone) {
            return temp;
          }
          return getToken(read());
        }
    }
  }

  @override
  int index = 0;

  @override
  bool get isDone => index >= tokens.length;

  @override
  peek() {
    if (isDone) {
      throw Exception('Cannot peek at end of input');
    }
    return tokens[index];
  }

  @override
  read() {
    if (isDone) {
      throw Exception('Cannot read at end of input');
    }
    return tokens[index++];
  }
}

