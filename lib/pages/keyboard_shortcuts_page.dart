import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/features/keyboard_shortcuts.dart';

class KeyboardShortcutsPage extends StatefulWidget {
  const KeyboardShortcutsPage({
    super.key,
    required this.map,
    required this.onSave,
  });
  final KeyboardShortcutMap map;
  final void Function(KeyboardShortcutMap) onSave;

  @override
  State<KeyboardShortcutsPage> createState() => _KeyboardShortcutsPageState();
}

class _KeyboardShortcutsPageState extends State<KeyboardShortcutsPage> {
  late KeyboardShortcutMap shortucts;
  LogicalKeyboardKey? selectedModifier;

  @override
  void initState() {
    super.initState();
    shortucts = widget.map.copyWith();
    selectedModifier = null;
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Text(
            'Select a modifier key to edit its shortcuts.',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton(
              selected: {selectedModifier},
              multiSelectionEnabled: false,
              onSelectionChanged: (value) {
                setState(() {
                  selectedModifier = value.first;
                });
              },
              segments: [
                const ButtonSegment(
                  label: Text('None'),
                  value: null,
                ),
                ButtonSegment(
                  label: Text(numpadKeyLabels[LogicalKeyboardKey.shift]!),
                  value: LogicalKeyboardKey.shift,
                ),
                if (Platform.isMacOS)
                  ButtonSegment(
                    label: Text(numpadKeyLabels[LogicalKeyboardKey.meta]!),
                    value: LogicalKeyboardKey.meta,
                  ),
                if (!Platform.isMacOS)
                  ButtonSegment(
                    label: Text(numpadKeyLabels[LogicalKeyboardKey.control]!),
                    value: LogicalKeyboardKey.control,
                  ),
                ButtonSegment(
                  label: Text(numpadKeyLabels[LogicalKeyboardKey.alt]!),
                  value: LogicalKeyboardKey.alt,
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 800,
              child: KeyboardShortcutsForm(
                key: Key(selectedModifier?.toString() ?? 'None'),
                shortcuts: shortucts.getShortcut(selectedModifier),
                onSave: (shortcuts) {
                  setState(() {
                    shortucts[selectedModifier] = shortcuts;
                    debugPrint(shortucts.toJson().toString());
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeyboardShortcutsForm extends StatefulWidget {
  const KeyboardShortcutsForm({
    super.key,
    required this.shortcuts,
    required this.onSave,
  });

  final KeyboardShortcut shortcuts;
  final void Function(KeyboardShortcut) onSave;

  @override
  State<KeyboardShortcutsForm> createState() => _KeyboardShortcutsFormState();
}

class _KeyboardShortcutsFormState extends State<KeyboardShortcutsForm> {
  late KeyboardShortcut shortucts;

  final _controllers = {
    LogicalKeyboardKey.numpad0: TextEditingController(),
    LogicalKeyboardKey.numpad1: TextEditingController(),
    LogicalKeyboardKey.numpad2: TextEditingController(),
    LogicalKeyboardKey.numpad3: TextEditingController(),
    LogicalKeyboardKey.numpad4: TextEditingController(),
    LogicalKeyboardKey.numpad5: TextEditingController(),
    LogicalKeyboardKey.numpad6: TextEditingController(),
    LogicalKeyboardKey.numpad7: TextEditingController(),
    LogicalKeyboardKey.numpad8: TextEditingController(),
    LogicalKeyboardKey.numpad9: TextEditingController(),
    LogicalKeyboardKey.numpadEnter: TextEditingController(),
    LogicalKeyboardKey.numpadDecimal: TextEditingController(),
    LogicalKeyboardKey.numpadAdd: TextEditingController(),
    LogicalKeyboardKey.numpadSubtract: TextEditingController(),
    LogicalKeyboardKey.numpadMultiply: TextEditingController(),
    LogicalKeyboardKey.numpadDivide: TextEditingController(),
    LogicalKeyboardKey.numpadEqual: TextEditingController(),
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
          widget.onSave(shortucts);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordered = <List<LogicalKeyboardKey?>>[
      [
        null,
        null,
        LogicalKeyboardKey.numpadDivide,
        LogicalKeyboardKey.numpadMultiply,
      ],
      [
        LogicalKeyboardKey.numpad7,
        LogicalKeyboardKey.numpad8,
        LogicalKeyboardKey.numpad9,
        LogicalKeyboardKey.numpadSubtract
      ],
      [
        LogicalKeyboardKey.numpad4,
        LogicalKeyboardKey.numpad5,
        LogicalKeyboardKey.numpad6,
        LogicalKeyboardKey.numpadAdd
      ],
      [
        LogicalKeyboardKey.numpad1,
        LogicalKeyboardKey.numpad2,
        LogicalKeyboardKey.numpad3,
        LogicalKeyboardKey.numpadEqual
      ],
      [
        LogicalKeyboardKey.numpad0,
        null,
        LogicalKeyboardKey.numpadDecimal,
        null,
      ],
    ];

    return Column(
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
                                      numpadKeyLabels[key] ?? key.keyLabel,
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
    );
  }
}

