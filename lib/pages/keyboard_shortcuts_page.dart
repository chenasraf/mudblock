import 'package:flutter/material.dart';

import '../core/keyboard_shortcuts.dart';

class KeyboardShortcutsPage extends StatefulWidget {
  const KeyboardShortcutsPage({super.key, required this.shortcuts, required this.onSave});

  final KeyboardShortcuts shortcuts;
  final void Function(KeyboardShortcuts) onSave;

  @override
  State<KeyboardShortcutsPage> createState() => _KeyboardShortcutsPageState();
}

class _KeyboardShortcutsPageState extends State<KeyboardShortcutsPage> {
  late KeyboardShortcuts shortucts;

  final _controllers = {
    NumpadKey.numpad0: TextEditingController(),
    NumpadKey.numpad1: TextEditingController(),
    NumpadKey.numpad2: TextEditingController(),
    NumpadKey.numpad3: TextEditingController(),
    NumpadKey.numpad4: TextEditingController(),
    NumpadKey.numpad5: TextEditingController(),
    NumpadKey.numpad6: TextEditingController(),
    NumpadKey.numpad7: TextEditingController(),
    NumpadKey.numpad8: TextEditingController(),
    NumpadKey.numpad9: TextEditingController(),
    NumpadKey.numpadEnter: TextEditingController(),
    NumpadKey.numpadDecimal: TextEditingController(),
    NumpadKey.numpadAdd: TextEditingController(),
    NumpadKey.numpadSubtract: TextEditingController(),
    NumpadKey.numpadMultiply: TextEditingController(),
    NumpadKey.numpadDivide: TextEditingController(),
    NumpadKey.numpadEqual: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    shortucts = widget.shortcuts.copyWith();
    _controllers.forEach((key, controller) {
      controller.text = shortucts.get(key);
      controller.addListener(() {
        setState(() {
          shortucts = shortucts.copyWithMap({key: controller.text});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordered = <List<NumpadKey?>>[
      [
        null,
        null,
        NumpadKey.numpadDivide,
        NumpadKey.numpadMultiply,
      ],
      [
        NumpadKey.numpad7,
        NumpadKey.numpad8,
        NumpadKey.numpad9,
        NumpadKey.numpadSubtract
      ],
      [
        NumpadKey.numpad4,
        NumpadKey.numpad5,
        NumpadKey.numpad6,
        NumpadKey.numpadAdd
      ],
      [
        NumpadKey.numpad1,
        NumpadKey.numpad2,
        NumpadKey.numpad3,
        NumpadKey.numpadEqual
      ],
      [
        NumpadKey.numpad0,
        null,
        NumpadKey.numpadDecimal,
        null,
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onSave(shortucts);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            children: ordered
                .map(
                  (row) => Row(
                    children: row
                        .map(
                          (key) => Expanded(
                            child: key != null
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      controller: _controllers[key],
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText:
                                            numpadKeyLabels[key] ?? key.name,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

