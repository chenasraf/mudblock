import 'dart:async';

import 'package:flutter/material.dart';

import 'widget_utils.dart';

class DialogUtils {
  static DialogButtons deleteButtons(
    BuildContext context, {
    required FutureOr<void> Function() onDelete,
    bool dismissOnDelete = true,
  }) {
    return DialogButtons.two(
      confirm: ElevatedButton(
        child: const Text('Delete'),
        onPressed: () {
          onDelete();
          if (dismissOnDelete) {
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

  static DialogButtons saveButtons(
    BuildContext context, {
    required FutureOr<void> Function() onSave,
    bool dismissOnSave = true,
  }) {
    return DialogButtons.two(
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
    return DialogButtons.one(
      child: ElevatedButton(
        child: const Text('Add'),
        onPressed: () {
          onAdd();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static yesNoButtons(
    BuildContext context, {
    required void Function() onYes,
    required void Function() onNo,
    bool dismissOnYes = true,
    bool dismissOnNo = true,
    bool revesed = false,
  }) {
    return DialogButtons.two(
      confirm: ElevatedButton(
        child: const Text('Yes'),
        onPressed: () {
          onYes();
          if (dismissOnYes) {
            Navigator.of(context).pop();
          }
        },
      ),
      dismiss: TextButton(
        child: const Text('No'),
        onPressed: () {
          onNo();
          if (dismissOnNo) {
            Navigator.of(context).pop();
          }
        },
      ),
      reversed: revesed,
    );
  }
}

class DialogButtons {
  final List<Widget> children;
  final double spacing;
  final bool reversed;

  DialogButtons({
    required this.children,
    this.spacing = 8,
    this.reversed = false,
  });

  DialogButtons.one({required Widget child})
      : children = [child],
        spacing = 0,
        reversed = false;

  DialogButtons.two({
    required Widget confirm,
    required Widget dismiss,
    this.spacing = 8,
    this.reversed = false,
  }) : children = [dismiss, confirm];

  Widget row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: spacing > 0 ? WidgetUtils.gap(children, spacing) : children,
    );
  }

  List<Widget> actions({bool includeSpacing = false}) {
    final widgets = reversed ? children.reversed.toList() : children;
    if (!includeSpacing || spacing == 0) {
      return widgets;
    }
    return WidgetUtils.gap(widgets, spacing);
  }
}

