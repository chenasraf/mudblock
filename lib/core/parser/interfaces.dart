import '../consts.dart' as consts;

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
      other is TokenValue &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          raw == other.raw;

  @override
  String toString() => token != Token.esc ? '${token.name}($raw)' : token.name;
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
  String toString() => 'Lex("$text", $fgColor:$bgColor)';
}

abstract class IReader<T> {
  T? read();
  T? peek();
  int get length;
  int get index;
  bool get isDone;
  void setPosition(int originalIndex);
}

abstract class ITokenizer {
  List<TokenValue> tokenize();
}

abstract class ILexer {
  List<LexerValue> lex();
}
