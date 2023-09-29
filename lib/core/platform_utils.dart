import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PlatformUtils {
  static get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static get isMobile => !isDesktop;

  static Future<String> getStorageBasePath() async {
    switch (Platform.operatingSystem) {
      case 'linux':
        final username =
            Platform.environment['USER'] ?? Platform.environment['USERNAME'];
        return '/Users/$username/.config/mudblock';
      case 'macos':
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
      case 'windows':
        final username = Platform.environment['USERNAME'];
        return 'C:\\Users\\$username\\AppData\\Roaming\\mudblock';
      case 'android':
        final base = await getExternalStorageDirectory();
        if (base == null) {
          throw UnsupportedError('External storage not available');
        }
        return path.join(base.path, 'mudblock');
      case 'ios':
        final base = await getApplicationDocumentsDirectory();
        return path.join(base.path, 'mudblock');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
