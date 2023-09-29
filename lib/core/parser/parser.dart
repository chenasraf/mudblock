import 'interfaces.dart';
import 'reader.dart';
import '../consts.dart' as consts;

class ColorToken {
  String text;
  int fgColor;
  int bgColor;
  bool bold;
  bool italic;
  bool underline;
  bool xterm256;

  ColorToken({
    required this.text,
    required this.fgColor,
    required this.bgColor,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.xterm256 = false,
  });

  factory ColorToken.empty() => ColorToken(text: '', fgColor: 0, bgColor: 0);
  factory ColorToken.defaultColor(String text) =>
      ColorToken(text: text, fgColor: 0, bgColor: 0);

  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    final b = bold ? 'b' : '';
    final i = italic ? 'i' : '';
    final u = underline ? 'u' : '';
    final x = xterm256 ? 'x' : '';
    final flags = '$b$i$u$x';
    return 'ColoredText("$text", $fgColor:$bgColor, $flags)';
  }

  @override
  int get hashCode => text.hashCode ^ fgColor.hashCode ^ bgColor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorToken &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          fgColor == other.fgColor &&
          bgColor == other.bgColor;
}

class ColorParser implements IReader {
  final IReader reader;
  final _tokens = <TokenValue>[];

  ColorParser._(this.reader);

  factory ColorParser(String text) => ColorParser._(StringReader(text));

  List<ColorToken> parse() {
    final lexed = <ColorToken>[];
    while (!reader.isDone) {
      final token = reader.read();
      var cur = getToken(token);
      lexed.add(cur);
    }
    return lexed;
  }

  ColorToken getToken(String char) {
    var token = ColorToken.empty();
    switch (char) {
      case consts.esc:
        String? next;
        // keep reading until we hit the end of the escape sequence or the end of the string
        while (!reader.isDone) {
          next = reader.peek();
          if (next == consts.esc) {
            break;
          }
          reader.read();
          if (next == '[') {
            final color = consumeUntil('m');
            reader.read();
            final colors = color.split(';');
            if (colors.length == 1) {
              final code = int.tryParse(colors[0]) ?? 0;
              if (code == consts.boldByte) {
                token.bold = true;
              } else if (code == consts.italicByte) {
                token.italic = true;
              } else if (code == consts.underlineByte) {
                token.underline = true;
              } else {
                token.fgColor = int.tryParse(colors[0]) ?? 0;
              }
            } else if (colors.length == 2) {
              token.bgColor = int.tryParse(colors[0]) ?? 1;
              token.fgColor = int.tryParse(colors[1]) ?? 0;
            } else if (colors.length == 3) {
              if (colors[0] == '38' && colors[1] == '5') {
                token.xterm256 = true;
                token.fgColor = int.tryParse(colors[2]) ?? 0;
              } else {
                token.bgColor = int.tryParse(colors[0]) ?? 1;
                token.fgColor = int.tryParse(colors[1]) ?? 0;
              }
            }
            token.text = consumeUntil(consts.esc);
            return token;
          }
          if (next == null) {
            break;
          }
          token.text += next;
        }
        return token;
      default:
        token.text += char;
        return token;
    }
  }

  String consumeUntil(String char) {
    String? next = reader.peek();
    if (next == null) {
      return '';
    }
    var result = '';
    while (!reader.isDone) {
      if (next == char) {
        break;
      }
      next = reader.peek();
      if (next == null) {
        break;
      }
      result += reader.read();
      next = reader.peek();
    }
    return result;
  }

  // String peekUntil(String char) {
  //   String? next = reader.peek();
  //   if (next == null) {
  //     return '';
  //   }
  //   var result = '';
  //   var originalIndex = reader.index;
  //   while (!reader.isDone) {
  //     if (next == char) {
  //       break;
  //     }
  //     next = reader.peek();
  //     if (next == null) {
  //       break;
  //     }
  //     result += reader.read();
  //     next = reader.peek();
  //   }
  //   reader.setPosition(originalIndex);
  //   return result;
  // }

  @override
  int index = 0;

  @override
  bool get isDone => index >= reader.length;

  @override
  peek() => _tokens[index];

  @override
  read() => _tokens[index++];

  @override
  int get length => _tokens.length;

  @override
  setPosition(int position) => index = position;
}
