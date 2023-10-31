import 'package:flutter/material.dart';

import '../core/dialog_utils.dart';

class WillConfirmPopScope extends StatelessWidget {
  const WillConfirmPopScope({
    super.key,
    required this.child,
    required this.dirty,
  });

  final Widget child;
  final bool dirty;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!dirty) {
          return true;
        }
        final res = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
                'Do you want to go back? Your changes would be lost'),
            actions: DialogUtils.yesNoButtons(
              context,
              onYes: () => Navigator.of(context).pop(true),
              onNo: () => Navigator.of(context).pop(false),
              dismissOnYes: false,
              dismissOnNo: false,
            ).actions(),
          ),
        );
        return res ?? false;
      },
      child: child,
    );
  }
}

