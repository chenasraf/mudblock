import 'package:flutter/material.dart';

import '../core/features/settings.dart';
import '../core/store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with GameStoreStateMixin {
  late Settings settings;

  @override
  void initState() {
    super.initState();
    debugPrint('SettingsPage.initState');
    settings = store.settings.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return GameStore.consumer(
      builder: (context, store, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Center(
            child: SizedBox(
            width: 600,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: settings.commandSeparator,
                    onChanged: (value) => settings.commandSeparator = value,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      labelText: 'Command Separator',
                      helperText:
                          'The character that separates commands. To send it literally, use it twice.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile.adaptive(
                    value: settings.echoCommands,
                    onChanged: (value) => setState(() => settings.echoCommands = value!),
                    title: const Text('Echo Commands'),
                    subtitle: const Text(
                        'Whether to echo commands to the screen as they are sent.'),
                  ),
                  CheckboxListTile.adaptive(
                    value: settings.showTimestamps,
                    onChanged: (value) => setState(() => settings.showTimestamps = value!),
                    title: const Text('Show Timestamps'),
                    subtitle: const Text(
                        'Whether to show timestamps on messages received from the server.'),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              store.currentProfile.saveSettings(settings);
              store.loadSettings();
              Navigator.pop(context);
            },
            child: const Icon(Icons.save),
          ),
        );
      },
    );
  }
}

