import 'package:flutter/material.dart';

import '../core/dialog_utils.dart';
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
    extends State<GameButtonLabelEditorDialog> with TickerProviderStateMixin {
  IconSelectorDisplay display = IconSelectorDisplay.grid;
  late final GameButtonLabelData data;
  late String search;
  late int tabIndex;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    data = widget.data.copyWith();
    debugPrint('data: ${data.iconName}');
    search = data.iconName ?? '';
    tabIndex = data.icon == null && data.label != null && data.label!.isNotEmpty
        ? 1
        : 0;
    tabController =
        TabController(vsync: this, length: tabs.length, initialIndex: tabIndex);
  }

  final tabs = [
    const Tab(text: 'Icon'),
    const Tab(text: 'Text/Emoji'),
  ];

  @override
  Widget build(BuildContext context) {
    final actions = DialogUtils.saveButtons(
      context,
      () => Navigator.pop(context, data),
      dismissOnSave: false,
    );
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
                const SizedBox(height: 16),
                TabBar(
                  controller: tabController,
                  tabs: tabs,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // height: tabIndex == 0 ? 400 : 100,
                  height: 400,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: search,
                                    onChanged: (value) =>
                                        setState(() => search = value),
                                    decoration: InputDecoration(
                                      labelText: 'Search Icon',
                                      suffixIcon: search.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () =>
                                                  setState(() => search = ''),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    display == IconSelectorDisplay.grid
                                        ? Icons.view_list
                                        : Icons.view_module,
                                  ),
                                  onPressed: () => setState(
                                    () => display =
                                        display == IconSelectorDisplay.grid
                                            ? IconSelectorDisplay.list
                                            : IconSelectorDisplay.grid,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 600,
                              child: IconSelector(
                                search: search,
                                display: display,
                                selectedIcon: data.icon,
                                onSelected: (icon, iconName) {
                                  setState(() {
                                    data.icon = icon;
                                    data.iconName = iconName;
                                    data.label = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        initialValue: data.label,
                        onChanged: (value) => setState(
                          () {
                            setState(() {
                              data.label = value;
                              data.icon = null;
                              data.iconName = null;
                            });
                          },
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Label',
                          helperText:
                              'You can use plain text or emojies to be shown on the button',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                actions.row(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

