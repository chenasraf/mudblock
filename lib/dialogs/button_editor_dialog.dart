import 'package:flutter/material.dart';

import '../core/dialog_utils.dart';
import '../core/features/action.dart';
import '../core/features/game_button.dart';
import '../core/string_utils.dart';
import 'game_button_label_editor_dialog.dart';

class ButtonEditorDialog extends StatefulWidget {
  const ButtonEditorDialog({
    super.key,
    this.data,
    required this.onSave,
  });

  final GameButtonData? data;
  final void Function(GameButtonData data) onSave;

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
    const interactions = GameButtonInteraction.values;
    final actions = DialogUtils.saveButtons(context, onSave: () {
      widget.onSave(data);
    });

    return Dialog(
      child: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Edit Button',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (final interaction in interactions)
                Builder(builder: (context) {
                  final label = data.getLabel(interaction);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                data.getAction(interaction)?.content ?? '',
                            decoration: InputDecoration(
                              label: Text(interaction.name.capitalize()),
                            ),
                            onChanged: (value) {
                              setState(() {
                                data.setAction(interaction, MUDAction(value));
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: GameButtonLabel(
                                data: label ?? GameButtonLabelData.empty(),
                              ),
                            ),
                          ),
                          onPressed: interaction ==
                                  GameButtonInteraction.longPress
                              ? null
                              : () async {
                                  final updated = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        GameButtonLabelEditorDialog(
                                      data:
                                          label ?? GameButtonLabelData.empty(),
                                    ),
                                  );
                                  if (updated != null) {
                                    setState(() {
                                      data.setLabel(interaction, updated);
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 32),
              actions.row(),
            ],
          ),
        ),
      ),
    );
  }
}

