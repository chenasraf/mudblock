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
    final baseFontSize = Theme.of(context).textTheme.bodyText1!.fontSize!;
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
              ListTile(
                title: const Text('UI Font Size'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Change the font size of the entire UI.'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: globalSettings.uiTextScale,
                            onChanged: (value) => setState(
                                () => globalSettings.uiTextScale = value),
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                          ),
                        ),
                        Text(
                            '${(globalSettings.uiTextScale * baseFontSize).toStringAsFixed(0)}pt (${(globalSettings.uiTextScale * 100).toStringAsFixed(0)}%)'),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Game Output Font Size'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Change the font size of the game output text.'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: globalSettings.gameTextScale,
                            onChanged: (value) => setState(
                                () => globalSettings.gameTextScale = value),
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                          ),
                        ),
                        Text(
                            '${(globalSettings.gameTextScale * baseFontSize).toStringAsFixed(0)}pt (${(globalSettings.gameTextScale*100).toStringAsFixed(0)}%)'),
                      ],
                    ),
                  ],
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

