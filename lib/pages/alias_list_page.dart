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
            itemBuilder: (context, item) => ListTile(
              key: Key(aliases[item].id),
              title: Text(aliases[item].pattern),
              subtitle: Text(aliases[item].action.content),
              onTap: () async {
                final alias = await Navigator.pushNamed(
                  context,
                  Paths.alias,
                  arguments: aliases[item],
                );
                if (alias != null) {
                  await store.currentProfile.saveAlias(alias as Alias);
                  await store.loadAliases();
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
          final alias = await Navigator.pushNamed(context, Paths.alias);
          if (alias != null) {
            await store.currentProfile.saveAlias(alias as Alias);
            await store.loadAliases();
          }
        },
      ),
    );
  }
}

