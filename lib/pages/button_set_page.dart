import 'package:flutter/material.dart';

import '../core/features/action.dart';
import '../core/features/game_button.dart';
import '../core/features/game_button_set.dart';
import '../core/platform_utils.dart';

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
    buttonSet = widget.buttonSet?.copyWith() ?? GameButtonSetData.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Set'),
        // actions: [
        //   Switch.adaptive(
        //     value: buttonSet.enabled,
        //     onChanged: (value) {
        //       buttonSet.enabled = value;
        //     },
        //   )
        // ],
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
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        controller: TextEditingController(
                          text: buttonSet.name,
                        ),
                        onChanged: (value) {
                          buttonSet.name = value;
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
                          buttonSet.type = value as GameButtonSetType;
                        },
                      ),
                      const SizedBox(height: 16),
                      ButtonSetEditor(data: buttonSet),
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
        final data = this.data.buttons[index];
        return Container(
          color: Colors.grey,
          child: data != null
              ? FakeGameButton(
                  label: data.label,
                  size: data.size ?? GameButtonData.defaultSize,
                  spacing: this.data.spacing,
                  onEdit: () {
                    showDialog(
                      context: context,
                      builder: (context) => ButtonEditorDialog(data: data),
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
        data: GameButtonData.empty().copyWith(
          label: label,
          pressAction: MUDAction.empty(),
          longPressAction: MUDAction.empty(),
          swipeUpAction: MUDAction.empty(),
          swipeDownAction: MUDAction.empty(),
          swipeLeftAction: MUDAction.empty(),
          swipeRightAction: MUDAction.empty(),
        ),
      ),
    );
  }
}

class ButtonEditorDialog extends StatefulWidget {
  const ButtonEditorDialog({
    super.key,
    this.data,
  });

  final GameButtonData? data;

  @override
  State<ButtonEditorDialog> createState() => _ButtonEditorDialogState();
}

class _ButtonEditorDialogState extends State<ButtonEditorDialog> {
  late final GameButtonData data;

  @override
  void initState() {
    data = widget.data?.copyWith() ?? GameButtonData.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final direction in GameButtonDirection.values)
                TextFormField(
                  initialValue:
                      data.actionForDirection(direction)?.content ?? '',
                  decoration: InputDecoration(
                    label: Text("${direction.name} action"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

