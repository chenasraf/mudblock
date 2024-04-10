import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mudblock/core/background_service.dart';

import 'core/platform_utils.dart';
import 'core/routes.dart';
import 'core/storage/shared_prefs.dart';
import 'core/store.dart';
import 'core/theme.dart';
import 'core/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initBackgroundService();
  await getPrefs();
  await gameStore.init();
  await windowInit();
  runApp(const MudblockApp());
}

class MudblockApp extends StatelessWidget {
  const MudblockApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const baseColor = Colors.blueGrey;
    final darkTheme =
        createTheme(seedColor: baseColor, brightness: Brightness.dark);

    return MaterialApp(
      title: 'Mudblock',
      theme: darkTheme,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return GameStore.provider(
          builder: (context, child) {
            return GameStore.consumer(
              builder: (context, store, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler:
                      TextScaler.linear(store.globalSettings.uiTextScale),
                ),
                child: child!,
              ),
              child: Container(
                color: darkTheme.colorScheme.background,
                child: Padding(
                  padding: PlatformUtils.isDesktop
                      ? EdgeInsets.only(top: Platform.isMacOS ? 28.0 : 32.0)
                      : EdgeInsets.zero,
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
      initialRoute: Paths.home,
      routes: routes,
    );
  }
}

