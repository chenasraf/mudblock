import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'platform_utils.dart';
import 'storage/shared_prefs.dart';

Future<void> windowInit() async {
  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();

    final w = prefs.getInt('windowWidth') ?? 1000;
    final h = prefs.getInt('windowHeight') ?? 900;
    final size = Size(w.toDouble(), h.toDouble());

    final x = prefs.getInt('windowX') ?? 0;
    final y = prefs.getInt('windowY') ?? 0;
    final position = Offset(x.toDouble(), y.toDouble());

    WindowOptions windowOptions = WindowOptions(
      size: size,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPosition(position);
    });
  }
}

