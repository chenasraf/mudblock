import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GameStoreMixin {
  final TextEditingController _input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
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
                          TextSpan(text: lines[index], style: textStyle),
                        ],
                      ),
                    );
                  },
                  itemCount: lines.length,
                );
              },
            ),
          ),
          TextField(
            controller: _input,
            onSubmitted: (text) {
              store.submitInput(text);
            },
            style: textStyle,
            decoration: InputDecoration(
              hintText: 'Enter command',
              hintStyle: textStyle.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

