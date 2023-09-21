import 'package:flutter/foundation.dart';
import 'package:mudblock/core/consts.dart';

import 'color_parser.dart';

class ColorUtils {
  static stripColor(String text) {
    return text
            // esc
            // .replaceAll(esc, '')
            // .replaceAll(r'^[', '')
            // color
            .replaceAll(RegExp(esc + colorPatternRaw), '')

        // color
        // .replaceAll(RegExp(r'\[\d+m'), '')
        // esc
        // .replaceAll(String.fromCharCode(0xff), '');

        //
        ;
  }

  static Iterable<ColoredText> split(String line) {
    // return line.split(RegExp(esc + colorPatternRaw)).map(
    //       (raw) => ColoredText(
    //         text: stripColor(raw),
    //         color: 0,
    //         raw: raw,
    //       ),
    //     );

    final result = <ColoredText>[];
    final tokenizer = Tokenizer(StringReader(line));
    final tokens = Lexer(tokenizer).lex();
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      result.add(
        ColoredText(
          text: token.text,
          fgColor: token.fgColor,
          raw: token.text,
        ),
      );
    }

    return result;
  }
}

class ColoredText {
  final String text;
  final int fgColor;
  final String raw;

  ColoredText({
    required this.text,
    required this.fgColor,
    required this.raw,
  });

  int get themedColor => fgColor == 0 ? 0xFFFFFFFF : fgColor;
}

