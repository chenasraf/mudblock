import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/platform_utils.dart';
import 'core/routes.dart';
import 'core/storage/shared_prefs.dart';
import 'core/store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getPrefs();
  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();

    final w = prefs.getInt('windowWidth') ?? 1000;
    final h = prefs.getInt('windowHeight') ?? 900;
    final size = Size(w.toDouble(), h.toDouble());

    WindowOptions windowOptions = WindowOptions(
      size: size,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mudblock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return GameStore.provider(child: child!);
      },
      initialRoute: '/home',
      routes: routes,
    );
  }
}

