import 'package:flutter/material.dart';

import '../core/features/settings.dart';
import '../core/store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    required this.globalSettings,
    required this.onSave,
  });

  final Settings? settings;
  final GlobalSettings globalSettings;
  final void Function(Settings?, GlobalSettings) onSave;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with GameStoreStateMixin {
  late Settings? settings;
  late GlobalSettings globalSettings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings?.copyWith();
    globalSettings = widget.globalSettings.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView(
            children: [
              if (settings != null) ...[
                Text('Profile Settings',
                    style: Theme.of(context).textTheme.titleMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    initialValue: settings!.commandSeparator,
                    onChanged: (value) => settings!.commandSeparator = value,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      labelText: 'Command Separator',
                      helperText:
                          'The character that separates commands.\nTo send it literally, use it twice.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile.adaptive(
                  value: settings!.echoCommands,
                  onChanged: (value) =>
                      setState(() => settings!.echoCommands = value!),
                  title: const Text('Echo Commands'),
                  subtitle: const Text(
                    'Whether to echo commands to the screen as they are sent.',
                  ),
                ),
                CheckboxListTile.adaptive(
                  value: settings!.showTimestamps,
                  onChanged: (value) =>
                      setState(() => settings!.showTimestamps = value!),
                  title: const Text('Show Timestamps'),
                  subtitle: const Text(
                    'Whether to show timestamps on messages received from the server.',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text('Global Settings',
                  style: Theme.of(context).textTheme.titleMedium),
              CheckboxListTile.adaptive(
                value: globalSettings.keepAwake,
                onChanged: (value) =>
                    setState(() => globalSettings.keepAwake = value!),
                title: const Text('Keep Screen Awake'),
                subtitle: const Text(
                  'Enabling this will make sure the screen doesn\'t turn off while a session is running.',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onSave(settings, globalSettings),
        child: const Icon(Icons.save),
      ),
    );
  }
}

