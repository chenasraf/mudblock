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
        final theme = Theme.of(context);
        final button = data.buttons[index];
        final size = button?.size ?? GameButtonData.defaultSize;
        final Widget child = button != null
            ? FakeGameButton(label: button.label)
            : const Icon(Icons.add, color: Colors.white);
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: button == null
                ? theme.dividerColor.withOpacity(0.2)
                : theme.dividerColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          // color: Colors.grey,
          child: GameButtonWrapper(
            size: size,
            isEmpty: button == null,
            onAdd: () {
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
            onEdit: () {
              showDialog(
                context: context,
                builder: (context) => ButtonEditorDialog(
                  data: button,
                  onSave: (data) {
                    setState(() {
                      this.data.buttons[index] = data;
                      widget.onUpdate(this.data);
                    });
                  },
                ),
              );
            },
            onDelete: () {
              setState(() {
                data.buttons.removeAt(index);
              });
            },
            onClear: () {
              setState(() {
                data.buttons[index] = null;
              });
            },
            emptySpaceControls: data.type == GameButtonSetType.grid
                ? _gridMenuItems(index)
                : data.type == GameButtonSetType.row
                    ? _rowMenuItems(index)
                    : _columnMenuItems(index),
            child: Padding(
              padding: EdgeInsets.all(data.spacing / 2),
              child: child,
            ),
          ),
        );
      },
    );
  }

  List<FakeGameButtonMenuItem> _columnMenuItems(int index) {
    return [
      FakeGameButtonMenuItem(
        value: 'add_above',
        label: 'Add above',
        onSelected: () {
          setState(() {
            data.buttons.insert(index, null);
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'add_below',
        label: 'Add below',
        onSelected: () {
          setState(() {
            data.buttons.insert(index + 1, null);
            widget.onUpdate(data);
          });
        },
      ),
    ];
  }

  List<FakeGameButtonMenuItem> _rowMenuItems(int index) {
    return [
      FakeGameButtonMenuItem(
        value: 'add_left',
        label: 'Add left',
        onSelected: () {
          setState(() {
            data.buttons.insert(index, null);
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'add_right',
        label: 'Add right',
        onSelected: () {
          setState(() {
            data.buttons.insert(index + 1, null);
            widget.onUpdate(data);
          });
        },
      ),
    ];
  }

  List<FakeGameButtonMenuItem> _gridMenuItems(int index) {
    return [
      FakeGameButtonMenuItem(
        value: 'add_row_above',
        label: 'Add row above',
        onSelected: () {
          final startOfRowIndex = index - (index % data.colCount);

          setState(() {
            data.buttons.insertAll(
              startOfRowIndex,
              List.generate(
                data.colCount,
                (index) => null,
              ),
            );
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'add_row_below',
        label: 'Add row below',
        onSelected: () {
          final rowIndices = data.getRowIndices(
            data.getRowFromIndex(index),
          );

          debugPrint('rowIndices: $rowIndices');

          setState(() {
            for (final index in rowIndices) {
              data.buttons.insert(
                index + data.colCount,
                null,
              );
            }
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'add_column_left',
        label: 'Add column left',
        onSelected: () {
          final btnIndices = data
              .getColumnIndices(
                data.getColumnFromIndex(index),
              )
              .reversed;
          debugPrint('btnIndices: $btnIndices');
          setState(() {
            for (final index in btnIndices) {
              data.buttons.insert(index, null);
            }
            data.crossAxisCount = data.colCount + 1;
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'add_column_right',
        label: 'Add column right',
        onSelected: () {
          final btnIndices = data
              .getColumnIndices(
                data.getColumnFromIndex(index),
              )
              .reversed;
          debugPrint('btnIndices: $btnIndices');
          setState(() {
            for (final index in btnIndices) {
              data.buttons.insert(index + 1, null);
            }
            data.crossAxisCount = data.colCount + 1;
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'remove_row',
        label: 'Remove row',
        onSelected: () {
          final rowIndices = data
              .getRowIndices(
                data.getRowFromIndex(index),
              )
              .reversed;
          setState(() {
            for (final index in rowIndices) {
              data.buttons.removeAt(index);
            }
            widget.onUpdate(data);
          });
        },
      ),
      FakeGameButtonMenuItem(
        value: 'remove_column',
        label: 'Remove column',
        onSelected: () {
          setState(() {
            final colIndices = data
                .getColumnIndices(
                  data.getColumnFromIndex(index),
                )
                .reversed;
            for (final index in colIndices) {
              data.buttons.removeAt(index);
            }
            widget.onUpdate(data);
          });
        },
      ),
    ];
  }

  Widget _buildContainer(
    BuildContext context,
    Widget Function(BuildContext context, int index) builder,
  ) {
    final size = Size(
      data.size.width + data.spacing * 6,
      data.size.height + data.spacing * 10,
    );
    return Center(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GameButtonSet.buildContainer(
              context: context,
              type: data.type,
              size: data.size,
              count: data.buttons.length,
              crossAxisCount: data.crossAxisCount,
              spacing: data.spacing / 3,
              alignment: data.alignment,
              builder: builder,
            ),
          ),
        ),
      ),
    );
  }
}

class GameButtonWrapper extends StatelessWidget {
  const GameButtonWrapper({
    super.key,
    required this.child,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onClear,
    required this.size,
    required this.isEmpty,
    this.emptySpaceControls = const [],
  });

  final Widget child;
  final void Function() onAdd;
  final void Function() onEdit;
  final void Function() onClear;
  final void Function() onDelete;
  final double size;
  final List<FakeGameButtonMenuItem> emptySpaceControls;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, size),
      tooltip: '',
      itemBuilder: (context) => [
        if (!isEmpty)
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
        if (isEmpty)
          const PopupMenuItem(
            value: 'add',
            child: Text('Add'),
          ),
        ...emptySpaceControls.map(
          (control) => PopupMenuItem(
            value: control.value,
            child: Text(control.label),
          ),
        ),
        if (!isEmpty)
          const PopupMenuItem(
            value: 'clear',
            child: Text('Clear'),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'add':
            onAdd();
          case 'edit':
            onEdit();
            break;
          case 'clear':
            onClear();
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
      child: child,
    );
  }
}

class FakeGameButton extends StatelessWidget {
  const FakeGameButton({
    super.key,
    required this.label,
  });

  final GameButtonLabelData label;

  @override
  Widget build(BuildContext context) {
    return GameButton(
      enabled: false,
      data: GameButtonData.empty().copyWith(label: label),
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

