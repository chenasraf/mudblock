import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
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
  final keyboardActionsMap = {
    KeyboardIntent: KeyboardAction(),
  };
  final keyboardIntentMap = {
    ...numpadKeysIntentMap,
    ...arrowKeysIntentMap,
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: keyboardIntentMap,
      child: Actions(
        actions: keyboardActionsMap,
        child: Focus(
          // onKeyEvent: (node, event) {
          //   debugPrint("Key event: ${event.logicalKey}");
          //   final intent = KeyboardIntent(event.logicalKey);
          //   final action = keyboardActionsMap[intent.runtimeType];
          //   debugPrint("Action: $action");
          //   if (action != null && action.isEnabled(intent, context)) {
          //     action.invoke(intent, context);
          //     return KeyEventResult.handled;
          //   }
          //   return KeyEventResult.ignored;
          // },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Material(
                  color: Colors.black,
                  child: GameStore.consumer(
                    builder: (context, store, child) {
                      final lines = store.lines;
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(
                            store.globalSettings.gameTextScale,
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              cursorColor: Colors.white,
                              selectionColor: Colors.white.withOpacity(0.3),
                              selectionHandleColor: Colors.white,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
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
                  style: consoleStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
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

  Widget _buildGameOutput(List<String> lines) {
    int? lastFgColor;
    final List<TextSpan> spans = [];
    for (final (lineIdx, line) in lines.indexed) {
      for (final segment
          in ColorUtils.split(line, lineIdx > 0 ? lastFgColor : null)) {
        spans.add(
          TextSpan(
            text: segment.text,
            style: consoleStyle.copyWith(
              color: Color(segment.themedFgColor),
              backgroundColor: Color(segment.themedBgColor),
              fontWeight: segment.bold ? FontWeight.w900 : FontWeight.w400,
              fontStyle: segment.italic ? FontStyle.italic : null,
              decoration: segment.underline ? TextDecoration.underline : null,
            ),
          ),
        );
        lastFgColor = segment.reset ? null : segment.fgColor;
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
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

