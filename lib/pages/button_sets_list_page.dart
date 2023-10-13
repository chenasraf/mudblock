import 'package:flutter/material.dart';

import '../core/features/game_button_set.dart';
import '../core/routes.dart';
import '../core/store.dart';
import 'generic_list_page.dart';

class ButtonSetListPage extends StatelessWidget with GameStoreMixin {
  const ButtonSetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Button Sets'),
      save: save,
      items: storeOf(context).currentProfile.buttonSets,
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
            }
          },
        ),
      ],
      itemBuilder: (context, store, buttonSet) {
        return ListTile(
          key: Key(buttonSet.id),
          title: Text(buttonSet.name),
          subtitle: Text('${buttonSet.nonEmptyButtons.length} buttons'),
          leading: Switch.adaptive(
            value: buttonSet.enabled,
            onChanged: (value) {
              buttonSet.enabled = value;
              save(store, buttonSet);
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
                  store.currentProfile.deleteButtonSet(buttonSet);
                  store.currentProfile.loadButtonSets();
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
              await save(store, updated as GameButtonSetData);
            }
          },
        );
      },
    );
  }

  Future<void> save(GameStore store, GameButtonSetData updated) async {
    await store.currentProfile.saveButtonSet(updated);
    // TODO - stop re-loading all triggers, only replace the one that changed
    await store.currentProfile.loadButtonSets();
  }
}

