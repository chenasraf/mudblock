import 'package:flutter/widgets.dart';

const newline = '\n';
const cr = '\r';
const lf = '\n';
// const ansiEscapePattern = r'\x1B\[[0-?]*[ -/]*[@-~]';
// final esc = String.fromCharCodes([0xff]);
const esc = '\x1B';
const colorPatternRaw = r'\[\d*m';

const boldByte = 1;
const italicByte = 3;
const underlineByte = 4;
final homeKey = GlobalKey(debugLabel: 'Home');
