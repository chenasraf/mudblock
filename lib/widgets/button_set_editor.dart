import 'package:flutter/material.dart';

import '../core/features/game_button.dart';
import '../core/features/game_button_set.dart';
import '../dialogs/button_editor_dialog.dart';

class ButtonSetEditor extends StatefulWidget {
  const ButtonSetEditor({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  final GameButtonSetData? data;
  final void Function(GameButtonSetData data) onUpdate;

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
                  onDelete: () {
                    setState(() {
                      data.buttons[index] = null;
                    });
                  },
                  emptySpaceControls: [
                    FakeGameButtonMenuItem(
                      value: 'add_row_above',
                      label: 'Add row above',
                      onSelected: () {
                        final colCount = data.crossAxisCount ?? 3;
                        final startOfRowIndex = index - (index % colCount);

                        setState(() {
                          data.buttons.insertAll(
                            startOfRowIndex,
                            List.generate(
                              colCount,
                              (index) => null,
                            ),
                          );
                          widget.onUpdate(data);
                        });
                      },
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ButtonEditorDialog(
                        onSave: (data) {
                          setState(() {
                            this.data.buttons[index] = data;
                            widget.onUpdate(this.data);
                          });
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildContainer(
    BuildContext context,
    Widget Function(BuildContext context, int index) builder,
  ) {
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
    required this.onDelete,
    required this.size,
    required this.spacing,
    this.emptySpaceControls = const [],
  });

  final GameButtonLabelData label;
  final void Function() onEdit;
  final void Function() onDelete;
  final double size;
  final double spacing;
  final List<FakeGameButtonMenuItem> emptySpaceControls;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, size),
      tooltip: '',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
        ...emptySpaceControls.map(
          (control) => PopupMenuItem(
            value: control.value,
            child: Text(control.label),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          default:
            final control = emptySpaceControls.firstWhere(
              (control) => control.value == value,
              orElse: () => FakeGameButtonMenuItem(
                value: '',
                label: '',
                onSelected: () {},
              ),
            );
            if (control.value.isNotEmpty) {
              control.onSelected();
            } else {
              throw Exception('Unknown value: $value');
            }
        }
      },
      child: GameButton(
        enabled: false,
        data: GameButtonData.empty().copyWith(label: label),
      ),
    );
  }
}

class FakeGameButtonMenuItem {
  final String value;
  final String label;
  final void Function() onSelected;

  const FakeGameButtonMenuItem({
    required this.value,
    required this.label,
    required this.onSelected,
  });
}

