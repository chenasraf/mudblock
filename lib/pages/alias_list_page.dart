import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/alias.dart';
import '../core/routes.dart';

class AliasListPage extends StatelessWidget with GameStoreMixin {
  const AliasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aliases'),
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          debugPrint('Alias list rebuild');
          final aliases = store.aliases;
          return ListView.builder(
            itemCount: aliases.length,
            itemBuilder: (context, item) {
              final alias = aliases[item];
              return ListTile(
                key: Key(alias.id),
                title: Text(alias.pattern),
                subtitle: Text(alias.action.content),
                leading: Switch.adaptive(
                  value: alias.enabled,
                  onChanged: (value) {
                    alias.enabled = value;
                    save(store, alias);                  },
                ),
                onTap: () async {
                  final updated = await Navigator.pushNamed(
                    context,
                    Paths.alias,
                    arguments: alias,
                  );
                  if (updated != null) {
                    await save(store, updated as Alias);
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
          final alias = await Navigator.pushNamed(context, Paths.alias);
          if (alias != null) {
            save(store, alias as Alias);          }
        },
      ),
    );
  }

  Future<void> save(GameStore store, Alias updated) async {
    await store.currentProfile.saveAlias(updated);
    // TODO - stop re-loading all aliases, only replace the one that changed
    await store.loadAliases();
  }
}

