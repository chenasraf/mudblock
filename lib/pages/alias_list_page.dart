import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';
import 'package:provider/provider.dart';

import '../core/features/alias.dart';

class AliasListPage extends StatelessWidget with GameStoreMixin {
  const AliasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    var store = storeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aliases'),
      ),
      body: Consumer<GameStore>(
        builder: (context, store, child) {
          final aliases = store.aliases;
          return ListView.builder(
            itemCount: aliases.length,
            itemBuilder: (context, item) => ListTile(
              title: Text(aliases[item].pattern),
              subtitle: Text(aliases[item].action.content),
              onTap: () {
                Navigator.pushNamed(context, '/alias',
                    arguments: aliases[item]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final alias = await Navigator.pushNamed(context, '/alias');
          if (alias != null) {
            store.currentProfile.saveAlias(alias as Alias);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

