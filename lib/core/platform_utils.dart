import 'dart:io';

class PlatformUtils {
  static get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static get isMobile => !isDesktop;
}

