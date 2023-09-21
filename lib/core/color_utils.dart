import 'package:flutter/foundation.dart';
import 'package:mudblock/core/consts.dart';

class ColorUtils {
  static stripColor(String text) {
    return text
      // esc
      // .replaceAll(esc, '')
      // .replaceAll(r'^[', '')
      // color
      .replaceAll(RegExp(esc + r'\[\d*m'), '')

      // color
      // .replaceAll(RegExp(r'\[\d+m'), '')
      // esc
      // .replaceAll(String.fromCharCode(0xff), '');

      //
      ;
  }
}

