import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../core/color_utils.dart';
import '../core/features/game_button_set.dart';
import '../core/features/keyboard_shortcuts.dart';
import '../core/notification_controller.dart';
import '../core/platform_utils.dart';
import '../core/storage/shared_prefs.dart';
import '../core/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with GameStoreStateMixin, WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    Future.delayed(Duration.zero, () => store.appStart(context));

    _initNotifications();
  }

  void _initNotifications() {
    if (!PlatformUtils.isMobile) {
      return;
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  final consoleStyle = const TextStyle(
    color: Colors.white,
    fontFamily: 'Fira Code',
    fontSize: 16,
    height: 1,
  );
  TextStyle get inputStyle => consoleStyle.copyWith(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: numpadKeysIntentMap,
      child: Actions(
        actions: {
          KeyboardIntent: KeyboardAction(),
        },
        child: Focus(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Material(
                  color: Colors.black,
                  child: Consumer<GameStore>(
                    builder: (context, store, child) {
                      final lines = store.lines;
                      return Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: Colors.white,
                            selectionColor: Colors.white.withOpacity(0.3),
                            selectionHandleColor: Colors.white,
                          ),
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: store.selectInput,
                              child: SingleChildScrollView(
                                controller: store.scrollController,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Focus(
                                    child: _buildGameOutput(lines),
                                  ),
                                ),
                              ),
                            ),
                            if (store.connected)
                              for (final buttonSet in store
                                  .currentProfile.buttonSets
                                  .where((b) => b.enabled))
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GameButtonSet(data: buttonSet),
                                )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  focusNode: store.inputFocus,
                  controller: store.input,
                  onSubmitted: store.submitAsInput,
                  onTap: store.selectInput,
                  style: consoleStyle.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter command',
                    border: const OutlineInputBorder(),
                    hintStyle: inputStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SelectableText _buildGameOutput(List<String> lines) {
    return SelectableText.rich(
      TextSpan(
        children: [
          for (final line in lines) ...[
            for (final segment in ColorUtils.split(line))
              TextSpan(
                text: segment.text,
                style: consoleStyle.copyWith(
                  color: Color(segment.themedFgColor),
                  backgroundColor: Color(segment.themedBgColor),
                  fontWeight: segment.bold ? FontWeight.w900 : FontWeight.w400,
                  fontStyle: segment.italic ? FontStyle.italic : null,
                  decoration:
                      segment.underline ? TextDecoration.underline : null,
                ),
              ),
            // const TextSpan(
            //   text: newline,
            //   style:
            //       consoleStyle, // .copyWith(fontSize: 1),
            // ),
          ],
        ],
      ),
      enableInteractiveSelection: true,
      selectionWidthStyle: BoxWidthStyle.tight,
      selectionHeightStyle: BoxHeightStyle.max,
    );
  }

  @override
  onWindowBlur() {
    debugPrint("Window blurred");
    store.unselectInput();
  }

  @override
  void onWindowFocus() {
    debugPrint("Window focused");
    store.selectInput();
  }

  @override
  void onWindowMove() {
    EasyDebounce.debounce(
      'windowMove',
      const Duration(milliseconds: 500),
      () async {
        final position = await windowManager.getPosition();
        debugPrint("Window moved to $position");
        prefs.setInt('windowX', position.dx.toInt());
        prefs.setInt('windowY', position.dy.toInt());
      },
    );
  }

  @override
  void onWindowResize() async {
    EasyDebounce.debounce(
      'windowResize',
      const Duration(milliseconds: 500),
      () async {
        final size = await windowManager.getSize();
        debugPrint("Window resized to $size");
        prefs.setInt('windowWidth', size.width.toInt());
        prefs.setInt('windowHeight', size.height.toInt());
      },
    );
  }
}

