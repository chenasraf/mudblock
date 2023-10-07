import 'package:flutter/material.dart';

import '../core/features/game_button_set.dart';
import '../widgets/button_set_editor.dart';

class GameButtonSetPage extends StatefulWidget {
  const GameButtonSetPage({super.key, required this.buttonSet});

  final GameButtonSetData? buttonSet;

  @override
  State<GameButtonSetPage> createState() => _GameButtonSetPageState();
}

class _GameButtonSetPageState extends State<GameButtonSetPage> {
  late GameButtonSetData buttonSet;

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
                        key: Key(buttonSet.type.name),
                        data: buttonSet,
                        onUpdate: (data) {
                          setState(() {
                            buttonSet = data;
                          });
                        },
                      ),
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

