import 'dart:async';

import 'package:flutter/material.dart';

import 'widget_utils.dart';

class DialogUtils {
  static DialogButtons saveButtons(
    BuildContext context, {
    required FutureOr<void> Function() onSave,
    bool dismissOnSave = true,
  }) {
    return DialogButtons.confirm(
      confirm: ElevatedButton(
        child: const Text('Save'),
        onPressed: () {
          onSave();
          if (dismissOnSave) {
            Navigator.of(context).pop();
          }
        },
      ),
      dismiss: TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static DialogButtons addButton(
    BuildContext context, {
    required FutureOr<void> Function() onAdd,
  }) {
    return DialogButtons.single(
      child: ElevatedButton(
        child: const Text('Add'),
        onPressed: () {
          onAdd();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class DialogButtons {
  final List<Widget> children;
  final double spacing;

  DialogButtons({required this.children, this.spacing = 8});

  DialogButtons.single({required Widget child})
      : children = [child],
        spacing = 0;

  DialogButtons.confirm(
      {required Widget confirm, required Widget dismiss, this.spacing = 8})
      : children = [dismiss, confirm];

  Widget row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: spacing > 0
          ? WidgetUtils.join(children, SizedBox(width: spacing))
          : children,
    );
  }
}

