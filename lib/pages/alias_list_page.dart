import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/alias.dart';
import '../core/routes.dart';
import 'generic_list_page.dart';

class AliasListPage extends StatelessWidget with GameStoreMixin {
  const AliasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Aliases'),
      save: save,
      items: storeOf(context).currentProfile.aliases,
      detailsPath: Paths.alias,
      displayName: (alias) => alias.pattern,
      searchTags: (alias) => [
        alias.action.content,
        alias.group,
      ],
      itemBuilder: (context, store, alias) {
        return ListTile(
          key: Key(alias.id),
          title: Text(alias.pattern),
          subtitle: Text(alias.action.content.replaceAll('\n', ' ')),
          leading: Switch.adaptive(
            value: alias.enabled,
            onChanged: (value) {
              alias.enabled = value;
              save(store, alias);
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
                  store.currentProfile.deleteAlias(alias);
                  store.currentProfile.loadAliases();
                  break;
              }
            },
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
  }

  Future<void> save(GameStore store, Alias updated) async {
    await store.currentProfile.saveAlias(updated);
    // TODO - stop re-loading all aliases, only replace the one that changed
    await store.currentProfile.loadAliases();
  }
}
