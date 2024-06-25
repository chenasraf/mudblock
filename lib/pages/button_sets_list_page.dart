import 'package:flutter/material.dart';

import '../core/features/game_button_set.dart';
import '../core/routes.dart';
import '../core/store.dart';
import 'generic_list_page.dart';

class ButtonSetListPage extends StatelessWidget with GameStoreMixin {
  const ButtonSetListPage({
    super.key,
    required this.buttonSets,
    required this.onSave,
    required this.onDelete,
  });

  final List<GameButtonSetData> buttonSets;
  final Future<void> Function(GameButtonSetData) onSave;
  final Future<void> Function(GameButtonSetData) onDelete;

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Button Sets'),
      save: onSave,
      items: buttonSets,
      detailsPath: Paths.buttonSet,
      displayName: (buttonSet) => buttonSet.name,
      searchTags: (buttonSet) => [
        buttonSet.group,
      ],
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'navigation_preset',
                child: Text('Create: Navigation Preset'),
              ),
              const PopupMenuItem(
                value: '1_btn_navigation_preset',
                child: Text('Create: 1-Button Navigation Preset'),
              ),
            ];
          },
          onSelected: (value) async {
            final store = storeOf(context);
            switch (value) {
              case 'navigation_preset':
                final data = await Navigator.pushNamed(
                  context,
                  Paths.buttonSet,
                  arguments: movementPreset,
                );
                if (data != null) {
                  store.currentProfile.saveButtonSet(data as GameButtonSetData);
                  store.currentProfile.loadButtonSets();
                }
                break;
              case '1_btn_navigation_preset':
                final data = await Navigator.pushNamed(
                  context,
                  Paths.buttonSet,
                  arguments: oneBtnMovementPreset,
                );
                if (data != null) {
                  store.currentProfile.saveButtonSet(data as GameButtonSetData);
                  store.currentProfile.loadButtonSets();
                }
                break;
            }
          },
        ),
      ],
      itemBuilder: (context, buttonSet) {
        return ListTile(
          key: Key(buttonSet.id),
          title: Text(buttonSet.name),
          subtitle: Text('${buttonSet.nonEmptyButtons.length} buttons'),
          leading: Switch.adaptive(
            value: buttonSet.enabled,
            onChanged: (value) {
              buttonSet.enabled = value;
              onSave(buttonSet);
            },
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  onDelete(buttonSet);
                  break;
              }
            },
          ),
          onTap: () async {
            final updated = await Navigator.pushNamed(
              context,
              Paths.buttonSet,
              arguments: buttonSet,
            );
            if (updated != null) {
              await onSave(updated as GameButtonSetData);
            }
          },
        );
      },
    );
  }
}

