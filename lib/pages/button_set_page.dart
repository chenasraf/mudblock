import 'package:flutter/material.dart';

import '../core/dialog_utils.dart';
import '../core/features/action.dart';
import '../core/features/game_button.dart';
import '../core/features/game_button_set.dart';
import '../core/string_utils.dart';
import '../dialogs/button_editor_dialog.dart';
import '../dialogs/game_button_label_editor_dialog.dart';

class GameButtonSetPage extends StatefulWidget {
  const GameButtonSetPage({super.key, required this.buttonSet});

  final GameButtonSetData? buttonSet;

  @override
  State<GameButtonSetPage> createState() => _GameButtonSetPageState();
}

class _GameButtonSetPageState extends State<GameButtonSetPage> {
  late final GameButtonSetData buttonSet;

  @override
  void initState() {
    buttonSet = widget.buttonSet?.copyWith() ??
        GameButtonSetData.empty().copyWith(buttons: [null, null, null]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Set'),
        actions: [
          Switch.adaptive(
            value: buttonSet.enabled,
            onChanged: (value) {
              buttonSet.enabled = value;
            },
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 1200,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        initialValue: buttonSet.name,
                        onChanged: (value) {
                          buttonSet.name = value;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Group',
                        ),
                        initialValue: buttonSet.group,
                        onChanged: (value) {
                          buttonSet.group = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownMenu(
                        label: const Text('Type'),
                        initialSelection: buttonSet.type,
                        dropdownMenuEntries: GameButtonSetType.values
                            .map(
                              (e) => DropdownMenuEntry(
                                value: e,
                                label: e.name,
                              ),
                            )
                            .toList(),
                        onSelected: (value) {
                          setState(() {
                            buttonSet.type = value as GameButtonSetType;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ButtonSetEditor(
                          key: Key(buttonSet.type.name), data: buttonSet),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, buttonSet);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

class ButtonSetEditor extends StatefulWidget {
  const ButtonSetEditor({
    super.key,
    required this.data,
  });

  final GameButtonSetData? data;

  @override
  State<ButtonSetEditor> createState() => _ButtonSetEditorState();
}

class _ButtonSetEditorState extends State<ButtonSetEditor> {
  late final GameButtonSetData data;

  @override
  void initState() {
    data = widget.data?.copyWith() ?? GameButtonSetData.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context,
      (context, index) {
        final button = data.buttons[index];
        return Container(
          height: (button?.size ?? GameButtonData.defaultSize) - data.spacing,
          width: (button?.size ?? GameButtonData.defaultSize) - data.spacing,
          color: Colors.grey,
          child: button != null
              ? FakeGameButton(
                  label: button.label,
                  size: button.size ?? GameButtonData.defaultSize,
                  spacing: data.spacing,
                  onEdit: () {
                    showDialog(
                      context: context,
                      builder: (context) => ButtonEditorDialog(
                        data: button,
                        onSave: (data) {
                          setState(() {
                            this.data.buttons[index] = data;
                          });
                        },
                      ),
                    );
                  },
                )
              : Container(),
        );
      },
    );
  }

  Widget _buildContainer(BuildContext context,
      Widget Function(BuildContext context, int index) builder) {
    final size = data.size;
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: GameButtonSet.buildContainer(
          context: context,
          type: data.type,
          size: data.size,
          count: data.buttons.length,
          crossAxisCount: data.crossAxisCount,
          spacing: data.spacing,
          alignment: data.alignment,
          builder: builder,
        ),
      ),
    );
  }
}

class FakeGameButton extends StatelessWidget {
  const FakeGameButton({
    super.key,
    required this.label,
    required this.onEdit,
    required this.size,
    required this.spacing,
  });

  final GameButtonLabelData label;
  final void Function() onEdit;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, size),
      tooltip: '',
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        }
      },
      child: GameButton(
        enabled: false,
        data: GameButtonData.empty().copyWith(label: label),
      ),
    );
  }
}

