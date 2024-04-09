import 'package:flutter/material.dart';
import 'package:terminal_color_parser/terminal_color_parser.dart';

class ColorUtils {
  static stripColor(String text) {
    return split(text).map((e) => e.text).join();
  }

  static Iterable<ColoredText> split(String line) {
    try {
      final result = <ColoredText>[];
      final tokens = ColorParser(line).parse();

      for (final token in tokens) {
        result.add(ColoredText.fromToken(token));
      }

      return result;
    } catch (e, stack) {
      debugPrint('Error at line: $line');
      debugPrint('Split error: $e $stack');
      return [
        ColoredText.defaultColor(line),
      ];
    }
  }

  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static Brightness getBrightness(Color color) =>
      ThemeData.estimateBrightnessForColor(color);

  static bool isDark(Color color) => getBrightness(color) == Brightness.dark;
  static bool isLight(Color color) => getBrightness(color) == Brightness.light;
}

class ColoredText extends ColorToken {
  ColoredText({
    required super.text,
    required super.fgColor,
    required super.bgColor,
    super.styles,
    super.xterm256 = false,
  });

  factory ColoredText.empty() => ColoredText(text: '', fgColor: 0, bgColor: 0);
  factory ColoredText.defaultColor(String text) =>
      ColoredText(text: text, fgColor: 0, bgColor: 0);
  factory ColoredText.fromToken(ColorToken token) => ColoredText(
        text: token.text,
        fgColor: token.fgColor,
        bgColor: token.bgColor,
        styles: token.styles,
        xterm256: token.xterm256,
      );

  int get themedFgColor {
    return xterm256
        ? (xtermColorMap[fgColor] ?? xtermColorMap[15]!)
        : (ansiFgColorMap[fgColor] ?? ansiFgColorMap[97]!);
  }

  int get themedBgColor => ansiBgColorMap[bgColor] ?? 0x00000000;
}

/// map of ansi colors to flutter color ints
const ansiFgColorMap = {
  // color: black
  30: 0xFF000000,
  // color: red
  31: 0xFFCD0000,
  // color: green
  32: 0xFF00CD00,
  // color: yellow
  33: 0xFFCDCD00,
  // color: blue
  34: 0xFF0000EE,
  // color: magenta
  35: 0xFFCD00CD,
  // color: cyan
  36: 0xFF00CDCD,
  // color: white
  37: 0xFFE5E5E5,
  // color: bright black
  90: 0xFF7F7F7F,
  // color: bright red
  91: 0xFFFF0000,
  // color: bright green
  92: 0xFF00FF00,
  // color: bright yellow
  93: 0xFFFFFF00,
  // color: bright blue
  94: 0xFF5C5CFF,
  // color: bright magenta
  95: 0xFFFF00FF,
  // color: bright cyan
  96: 0xFF00FFFF,
  // color: bright white
  97: 0xFFFFFFFF,
};

const ansiBgColorMap = {
  40: 0xFF000000,
  41: 0xFF800000,
  42: 0xFF008000,
  43: 0xFF808000,
  44: 0xFF000080,
  45: 0xFF800080,
  46: 0xFF008080,
  47: 0xFFC0C0C0,
  100: 0xFF808080,
  101: 0xFFFF0000,
  102: 0xFF00FF00,
  103: 0xFFFFFF00,
  104: 0xFF0000FF,
  105: 0xFFFF00FF,
  106: 0xFF00FFFF,
  107: 0xFFFFFFFF,
};

/// map of xterm 256 colors to flutter color ints
const xtermColorMap = {
  0: 0xFF000000,
  1: 0xFF800000,
  2: 0xFF008000,
  3: 0xFF808000,
  4: 0xFF000080,
  5: 0xFF800080,
  6: 0xFF008080,
  7: 0xFFC0C0C0,
  8: 0xFF808080,
  9: 0xFFFF0000,
  10: 0xFF00FF00,
  11: 0xFFFFFF00,
  12: 0xFF0000FF,
  13: 0xFFFF00FF,
  14: 0xFF00FFFF,
  15: 0xFFFFFFFF,
  16: 0xFF000000,
  17: 0xFF00005F,
  18: 0xFF000087,
  19: 0xFF0000AF,
  20: 0xFF0000D7,
  21: 0xFF0000FF,
  22: 0xFF005F00,
  23: 0xFF005F5F,
  24: 0xFF005F87,
  25: 0xFF005FAF,
  26: 0xFF005FD7,
  27: 0xFF005FFF,
  28: 0xFF008700,
  29: 0xFF00875F,
  30: 0xFF008787,
  31: 0xFF0087AF,
  32: 0xFF0087D7,
  33: 0xFF0087FF,
  34: 0xFF00AF00,
  35: 0xFF00AF5F,
  36: 0xFF00AF87,
  37: 0xFF00AFAF,
  38: 0xFF00AFD7,
  39: 0xFF00AFFF,
  40: 0xFF00D700,
  41: 0xFF00D75F,
  42: 0xFF00D787,
  43: 0xFF00D7AF,
  44: 0xFF00D7D7,
  45: 0xFF00D7FF,
  46: 0xFF00FF00,
  47: 0xFF00FF5F,
  48: 0xFF00FF87,
  49: 0xFF00FFAF,
  50: 0xFF00FFD7,
  51: 0xFF00FFFF,
  52: 0xFF5F0000,
  53: 0xFF5F005F,
  54: 0xFF5F0087,
  55: 0xFF5F00AF,
  56: 0xFF5F00D7,
  57: 0xFF5F00FF,
  58: 0xFF5F5F00,
  59: 0xFF5F5F5F,
  60: 0xFF5F5F87,
  61: 0xFF5F5FAF,
  62: 0xFF5F5FD7,
  63: 0xFF5F5FFF,
  64: 0xFF5F8700,
  65: 0xFF5F875F,
  66: 0xFF5F8787,
  67: 0xFF5F87AF,
  68: 0xFF5F87D7,
  69: 0xFF5F87FF,
  70: 0xFF5FAF00,
  71: 0xFF5FAF5F,
  72: 0xFF5FAF87,
  73: 0xFF5FAFAF,
  74: 0xFF5FAFD7,
  75: 0xFF5FAFFF,
  76: 0xFF5FD700,
  77: 0xFF5FD75F,
  78: 0xFF5FD787,
  79: 0xFF5FD7AF,
  80: 0xFF5FD7D7,
  81: 0xFF5FD7FF,
  82: 0xFF5FFF00,
  83: 0xFF5FFF5F,
  84: 0xFF5FFF87,
  85: 0xFF5FFFAF,
  86: 0xFF5FFFD7,
  87: 0xFF5FFFFF,
  88: 0xFF870000,
  89: 0xFF87005F,
  90: 0xFF870087,
  91: 0xFF8700AF,
  92: 0xFF8700D7,
  93: 0xFF8700FF,
  94: 0xFF875F00,
  95: 0xFF875F5F,
  96: 0xFF875F87,
  97: 0xFF875FAF,
  98: 0xFF875FD7,
  99: 0xFF875FFF,
  100: 0xFF878700,
  101: 0xFF87875F,
  102: 0xFF878787,
  103: 0xFF8787AF,
  104: 0xFF8787D7,
  105: 0xFF8787FF,
  106: 0xFF87AF00,
  107: 0xFF87AF5F,
  108: 0xFF87AF87,
  109: 0xFF87AFAF,
  110: 0xFF87AFD7,
  111: 0xFF87AFFF,
  112: 0xFF87D700,
  113: 0xFF87D75F,
  114: 0xFF87D787,
  115: 0xFF87D7AF,
  116: 0xFF87D7D7,
  117: 0xFF87D7FF,
  118: 0xFF87FF00,
  119: 0xFF87FF5F,
  120: 0xFF87FF87,
  121: 0xFF87FFAF,
  122: 0xFF87FFD7,
  123: 0xFF87FFFF,
  124: 0xFFAF0000,
  125: 0xFFAF005F,
  126: 0xFFAF0087,
  127: 0xFFAF00AF,
  128: 0xFFAF00D7,
  129: 0xFFAF00FF,
  130: 0xFFAF5F00,
  131: 0xFFAF5F5F,
  132: 0xFFAF5F87,
  133: 0xFFAF5FAF,
  134: 0xFFAF5FD7,
  135: 0xFFAF5FFF,
  136: 0xFFAF8700,
  137: 0xFFAF875F,
  138: 0xFFAF8787,
  139: 0xFFAF87AF,
  140: 0xFFAF87D7,
  141: 0xFFAF87FF,
  142: 0xFFAFAF00,
  143: 0xFFAFAF5F,
  144: 0xFFAFAF87,
  145: 0xFFAFAFAF,
  146: 0xFFAFAFD7,
  147: 0xFFAFAFFF,
  148: 0xFFAFD700,
  149: 0xFFAFD75F,
  150: 0xFFAFD787,
  151: 0xFFAFD7AF,
  152: 0xFFAFD7D7,
  153: 0xFFAFD7FF,
  154: 0xFFAFFF00,
  155: 0xFFAFFF5F,
  156: 0xFFAFFF87,
  157: 0xFFAFFFAF,
  158: 0xFFAFFFD7,
  159: 0xFFAFFFFF,
  160: 0xFFD70000,
  161: 0xFFD7005F,
  162: 0xFFD70087,
  163: 0xFFD700AF,
  164: 0xFFD700D7,
  165: 0xFFD700FF,
  166: 0xFFD75F00,
  167: 0xFFD75F5F,
  168: 0xFFD75F87,
  169: 0xFFD75FAF,
  170: 0xFFD75FD7,
  171: 0xFFD75FFF,
  172: 0xFFD78700,
  173: 0xFFD7875F,
  174: 0xFFD78787,
  175: 0xFFD787AF,
  176: 0xFFD787D7,
  177: 0xFFD787FF,
  178: 0xFFD7AF00,
  179: 0xFFD7AF5F,
  180: 0xFFD7AF87,
  181: 0xFFD7AFAF,
  182: 0xFFD7AFD7,
  183: 0xFFD7AFFF,
  184: 0xFFD7D700,
  185: 0xFFD7D75F,
  186: 0xFFD7D787,
  187: 0xFFD7D7AF,
  188: 0xFFD7D7D7,
  189: 0xFFD7D7FF,
  190: 0xFFD7FF00,
  191: 0xFFD7FF5F,
  192: 0xFFD7FF87,
  193: 0xFFD7FFAF,
  194: 0xFFD7FFD7,
  195: 0xFFD7FFFF,
  196: 0xFFFF0000,
  197: 0xFFFF005F,
  198: 0xFFFF0087,
  199: 0xFFFF00AF,
  200: 0xFFFF00D7,
  201: 0xFFFF00FF,
  202: 0xFFFF5F00,
  203: 0xFFFF5F5F,
  204: 0xFFFF5F87,
  205: 0xFFFF5FAF,
  206: 0xFFFF5FD7,
  207: 0xFFFF5FFF,
  208: 0xFFFF8700,
  209: 0xFFFF875F,
  210: 0xFFFF8787,
  211: 0xFFFF87AF,
  212: 0xFFFF87D7,
  213: 0xFFFF87FF,
  214: 0xFFFFAF00,
  215: 0xFFFFAF5F,
  216: 0xFFFFAF87,
  217: 0xFFFFAFAF,
  218: 0xFFFFAFD7,
  219: 0xFFFFAFFF,
  220: 0xFFFFD700,
  221: 0xFFFFD75F,
  222: 0xFFFFD787,
  223: 0xFFFFD7AF,
  224: 0xFFFFD7D7,
  225: 0xFFFFD7FF,
  226: 0xFFFFFF00,
  227: 0xFFFFFF5F,
  228: 0xFFFFFF87,
  229: 0xFFFFFFAF,
  230: 0xFFFFFFD7,
  231: 0xFFFFFFFF,
  232: 0xFF080808,
  233: 0xFF121212,
  234: 0xFF1C1C1C,
  235: 0xFF262626,
  236: 0xFF303030,
  237: 0xFF3A3A3A,
  238: 0xFF444444,
  239: 0xFF4E4E4E,
  240: 0xFF585858,
  241: 0xFF626262,
  242: 0xFF6C6C6C,
  243: 0xFF767676,
  244: 0xFF808080,
  245: 0xFF8A8A8A,
  246: 0xFF949494,
  247: 0xFF9E9E9E,
  248: 0xFFA8A8A8,
  249: 0xFFB2B2B2,
  250: 0xFFBCBCBC,
  251: 0xFFC6C6C6,
  252: 0xFFD0D0D0,
  253: 0xFFDADADA,
  254: 0xFFE4E4E4,
  255: 0xFFEEEEEE,
};

