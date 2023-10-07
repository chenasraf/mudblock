import 'package:flutter/material.dart';

import '../core/features/game_button.dart';
import '../widgets/icon_selector.dart';

class GameButtonLabelEditorDialog extends StatefulWidget {
  const GameButtonLabelEditorDialog({super.key, required this.data});

  final GameButtonLabelData data;

  @override
  State<GameButtonLabelEditorDialog> createState() =>
      _GameButtonLabelEditorDialogState();
}

class _GameButtonLabelEditorDialogState
    extends State<GameButtonLabelEditorDialog> {
  String search = '';
  IconSelectorDisplay display = IconSelectorDisplay.grid;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Label',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => search = value),
                        decoration: const InputDecoration(
                          labelText: 'Search Icon',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        display == IconSelectorDisplay.grid
                            ? Icons.view_list
                            : Icons.view_module,
                      ),
                      onPressed: () => setState(() => display =
                          display == IconSelectorDisplay.grid
                              ? IconSelectorDisplay.list
                              : IconSelectorDisplay.grid),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 600,
                  child: IconSelector(
                    search: search,
                    display: display,
                    onSelected: (icon) {
                      Navigator.of(context).pop(icon);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
