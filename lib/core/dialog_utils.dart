import 'package:flutter/material.dart';

class DialogUtils {
  static DialogButtonSet saveButtons(
    BuildContext context,
    Function() onSave, {
    bool dismissOnSave = true,
  }) {
    return DialogButtonSet(
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
}

class DialogButtonSet {
  final Widget confirm;
  final Widget dismiss;

  DialogButtonSet({required this.confirm, required this.dismiss});

  Widget row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        dismiss,
        const SizedBox(width: 8),
        confirm,
      ],
    );
  }
}

