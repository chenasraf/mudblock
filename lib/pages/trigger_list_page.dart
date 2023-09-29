import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/trigger.dart';
import '../core/routes.dart';

class TriggerListPage extends StatelessWidget with GameStoreMixin {
  const TriggerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triggers'),
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          debugPrint('Trigger list rebuild');
          final triggers = store.triggers;
          return ListView.builder(
            itemCount: triggers.length,
            itemBuilder: (context, item) {
              final trigger = triggers[item];
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final store = storeOf(context);
          final trigger = await Navigator.pushNamed(context, Paths.trigger);
          if (trigger != null) {
            save(store, trigger as Trigger);
          }
        },
      ),
    );
  }

  Future<void> save(GameStore store, Trigger updated) async {
    await store.currentProfile.saveTrigger(updated);
    // TODO - stop re-loading all triggers, only replace the one that changed
    await store.loadTriggers();
  }
}
