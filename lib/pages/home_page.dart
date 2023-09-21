import 'package:flutter/material.dart';
import 'package:mudblock/core/color_utils.dart';
import 'package:provider/provider.dart';

import '../core/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GameStoreMixin {
  @override
  Widget build(BuildContext context) {
    const consoleStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Courier New',
      fontSize: 16,
    );
    final inputStyle = consoleStyle.copyWith(color: Colors.grey);

    return Column(
      children: [
        Expanded(
          child: Material(
            color: Colors.black,
            child: Consumer<GameStore>(
              builder: (context, store, child) {
                final lines = store.lines;
                return ListView.builder(
                  controller: store.scrollController,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ColorUtils.stripColor(lines[index]),
                            style: consoleStyle,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: lines.length,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
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
}

