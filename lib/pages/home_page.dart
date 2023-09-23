import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mudblock/core/color_utils.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../core/consts.dart';
import '../core/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GameStoreMixin, WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
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
      fontWeight: FontWeight.w500,
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
                  child: SingleChildScrollView(
                    controller: store.scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText.rich(
                        TextSpan(
                          children: [
                            for (final line in lines) ...[
                              for (final segment in ColorUtils.split(line))
                                TextSpan(
                                  text: segment.text,
                                  style: consoleStyle.copyWith(
                                    color: Color(segment.themedFgColor),
                                    backgroundColor: Color(segment.themedBgColor),
                                    fontWeight: segment.bold ? FontWeight.w800 : null,
                                    fontStyle: segment.italic ? FontStyle.italic : null,
                                    decoration: segment.underline ? TextDecoration.underline : null,
                                  ),
                                ),
                              TextSpan(
                                text: newline,
                                style: consoleStyle.copyWith(fontSize: 1),
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
            onSubmitted: (text) {
              store.submitInput(text);
            },
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
  void onWindowFocus() {
    debugPrint("Window focused");
    store.selectInput();
  }
}

