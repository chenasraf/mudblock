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
        title: const Text('Triggeres'),
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          debugPrint('Trigger list rebuild');
          final triggers = store.triggers;
          return ListView.builder(
            itemCount: triggers.length,
            itemBuilder: (context, item) => ListTile(
              key: Key(triggers[item].id),
              title: Text(triggers[item].pattern),
              subtitle: Text(triggers[item].action.content),
              onTap: () async {
                final trigger = await Navigator.pushNamed(
                  context,
                  Paths.trigger,
                  arguments: triggers[item],
                );
                if (trigger != null) {
                  await store.currentProfile.saveTrigger(trigger as Trigger);
                  await store.loadTriggers();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final store = storeOf(context);
          final trigger = await Navigator.pushNamed(context, Paths.trigger);
          if (trigger != null) {
            await store.currentProfile.saveTrigger(trigger as Trigger);
            await store.loadTriggers();
          }
        },
      ),
    );
  }
}

