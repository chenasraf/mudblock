import 'dart:ui';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:mudblock/core/color_utils.dart';
import 'package:mudblock/core/storage/shared_prefs.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../core/consts.dart';
import '../core/features/game_button_set.dart';
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
    Future.delayed(Duration.zero, () => store.connect(context));
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const consoleStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Menlo',
      fontSize: 16,
      height: 1,
    );
    final inputStyle = consoleStyle.copyWith(color: Colors.grey);

    return Column(
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
                        onTap: store.selectInput,
                        child: SingleChildScrollView(
                          controller: store.scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SelectableText.rich(
                              TextSpan(
                                children: [
                                  for (final line in lines) ...[
                                    for (final segment
                                        in ColorUtils.split(line))
                                      TextSpan(
                                        text: segment.text,
                                        style: consoleStyle.copyWith(
                                          color: Color(segment.themedFgColor),
                                          backgroundColor:
                                              Color(segment.themedBgColor),
                                          fontWeight: segment.bold
                                              ? FontWeight.w800
                                              : null,
                                          fontStyle: segment.italic
                                              ? FontStyle.italic
                                              : null,
                                          decoration: segment.underline
                                              ? TextDecoration.underline
                                              : null,
                                        ),
                                      ),
                                    const TextSpan(
                                      text: newline,
                                      style:
                                          consoleStyle, // .copyWith(fontSize: 1),
                                    ),
                                  ],
                                ],
                              ),
                              enableInteractiveSelection: true,
                              selectionWidthStyle: BoxWidthStyle.tight,
                              selectionHeightStyle: BoxHeightStyle.max,
                            ),
                          ),
                        ),
                      ),
                      for (final buttonSet in store.buttonSets)
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
            onSubmitted: store.submitInput,
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
