import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';
import 'package:provider/provider.dart';

import '../core/features/alias.dart';

class AliasListPage extends StatelessWidget with GameStoreMixin {
  const AliasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    var _store = storeOf(context);
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
                  '/alias',
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
          final alias = await Navigator.pushNamed(context, '/alias');
          if (alias != null) {
            await _store.currentProfile.saveAlias(alias as Alias);
            await _store.loadAliases();
          }
        },
      ),
    );
  }
}

