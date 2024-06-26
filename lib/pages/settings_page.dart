import 'package:flutter/material.dart';
import 'package:mudblock/core/platform_utils.dart';

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
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    settings = widget.settings?.copyWith();
    globalSettings = widget.globalSettings.copyWith();
    pageController = PageController(initialPage: 0);
    pageController.addListener(_notify);
    // pageController.animateToPage(0, duration: Duration.zero, curve: Curves.easeInOut);
    // HACK otherwise build is not notified of pageController clients
    Future.delayed(const Duration(milliseconds: 1)).then((_) => _notify());
  }

  void _notify() {
    setState(() {});
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pageController.hasClients) _buildSidebar(),
          _buildSettingsPages(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onSave(settings, globalSettings),
        child: const Icon(Icons.save),
      ),
    );
  }

  SizedBox _buildSettingsPages() {
    return SizedBox(
      width: 700,
      child: PageView(
        controller: pageController,
        children: [
          if (settings != null) _buildProfileSettings(),
          _buildGlobalSettings(),
        ],
      ),
    );
  }

  ListView _buildGlobalSettings() {
    final baseFontSize = Theme.of(context).textTheme.bodyMedium!.fontSize!;
    return ListView(
      children: [
        if (PlatformUtils.isMobile)
          CheckboxListTile.adaptive(
            value: globalSettings.keepAwake.value,
            onChanged: (value) =>
                setState(() => globalSettings.keepAwake.value = value!),
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
                      value: globalSettings.uiTextScale.value,
                      onChanged: (value) =>
                          setState(() => globalSettings.uiTextScale.value = value),
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                    ),
                  ),
                  Text(
                    _formatFontSize(baseFontSize, globalSettings.uiTextScale.value),
                  ),
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
                      value: globalSettings.gameTextScale.value,
                      onChanged: (value) =>
                          setState(() => globalSettings.gameTextScale.value = value),
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                    ),
                  ),
                  Text(
                    _formatFontSize(baseFontSize, globalSettings.gameTextScale.value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFontSize(double baseFontSize, double value) {
    final ptSize = (value * baseFontSize).toStringAsFixed(0);
    final percent = (value * 100).toStringAsFixed(0);
    return '${ptSize}pt ($percent%)';
  }

  ListView _buildProfileSettings() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            initialValue: settings!.commandSeparator.value,
            onChanged: (value) => settings!.commandSeparator.value = value,
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
          value: settings!.echoCommands.value,
          onChanged: (value) => setState(() => settings!.echoCommands.value = value!),
          title: const Text('Echo Commands'),
          subtitle: const Text(
            'Whether to echo commands to the screen as they are sent.',
          ),
        ),
        CheckboxListTile.adaptive(
          value: settings!.showTimestamps.value,
          onChanged: (value) =>
              setState(() => settings!.showTimestamps.value = value!),
          title: const Text('Show Timestamps'),
          subtitle: const Text(
            'Whether to show timestamps on messages received from the server.',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, String> get _sections => {
        if (settings != null) 'profile': 'Profile Settings',
        'ui': 'UI Settings',
      };

  SizedBox _buildSidebar() {
    final drawerTitleStyle = Theme.of(context).textTheme.titleMedium;

    return SizedBox(
      width: 300,
      child: ListView(
        children: _sections.entries.map(
          (entry) {
            final index = _sections.keys.toList().indexOf(entry.key);
            return ListTile(
              title: Text(entry.value, style: drawerTitleStyle),
              selected: pageController.page?.round() == index,
              onTap: () {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
            );
          },
        ).toList(),
      ),
    );
  }
}

