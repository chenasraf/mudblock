import 'package:flutter/material.dart';
import 'package:mudblock/core/consts.dart';
import 'package:mudblock/core/store.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/storage/shared_prefs.dart';
import 'pages/home_page.dart';
import 'pages/main_scaffold.dart';
import 'pages/profile_select_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getPrefs();
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
      initialRoute: '/home',
      routes: {
        '/select-profile': (context) => const ProfileSelectPage(),
        '/home': (context) => MainScaffold(
          builder: (context, _) {
            return HomePage(key: homeKey);
          }
        ),
      },
    );
  }
}

