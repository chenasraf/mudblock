import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/alias.dart';
import '../core/routes.dart';
import 'generic_list_page.dart';

class AliasListPage extends StatelessWidget with GameStoreMixin {
  const AliasListPage({
    super.key,
    required this.aliases,
    required this.onSave,
    required this.onDelete,
  });

  final List<Alias> aliases;
  final Future<void> Function(Alias) onSave;
  final Future<void> Function(Alias) onDelete;

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Aliases'),
      save: onSave,
      items: storeOf(context).currentProfile.aliases,
      detailsPath: Paths.alias,
      displayName: (alias) => alias.pattern,
      searchTags: (alias) => [
        alias.action.content,
        alias.group,
      ],
      itemBuilder: (context, alias) {
        return ListTile(
          key: Key(alias.id),
          title: Text(alias.pattern),
          subtitle: Text(alias.action.content.replaceAll('\n', ' ')),
          leading: Switch.adaptive(
            value: alias.enabled,
            onChanged: (value) {
              alias.enabled = value;
              onSave(alias);
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
                  onDelete(alias);
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
              await onSave(updated as Alias);
            }
          },
        );
      },
    );
  }

}

