import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/trigger.dart';
import '../core/routes.dart';
import 'generic_list_page.dart';

class TriggerListPage extends StatelessWidget with GameStoreMixin {
  const TriggerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Triggers'),
      save: save,
      items: storeOf(context).triggers,
      detailsPath: Paths.trigger,
      displayName: (trigger) => trigger.pattern,
      searchTags: (trigger) => [
        trigger.action.content,
        trigger.group,
      ],
      itemBuilder: (context, store, trigger) {
        return ListTile(
          key: Key(trigger.id),
          title: Text(trigger.pattern),
          subtitle: Text(trigger.action.content),
          leading: Switch.adaptive(
            value: trigger.enabled,
            onChanged: (value) {
              trigger.enabled = value;
              save(store, trigger);
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
                  store.currentProfile.deleteTrigger(trigger);
                  store.loadTriggers();
                  break;
              }
            },
          ),
          onTap: () async {
            final updated = await Navigator.pushNamed(
              context,
              Paths.trigger,
              arguments: trigger,
            );
            if (updated != null) {
              await save(store, updated as Trigger);
            }
          },
        );
      },
    );
  }

  Future<void> save(GameStore store, Trigger updated) async {
    await store.currentProfile.saveTrigger(updated);
    // TODO - stop re-loading all triggers, only replace the one that changed
    await store.loadTriggers();
  }
}

