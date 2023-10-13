import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/trigger.dart';
import '../core/routes.dart';
import 'generic_list_page.dart';

class TriggerListPage extends StatelessWidget with GameStoreMixin {
  const TriggerListPage({
    super.key,
    required this.triggers,
    required this.onSave,
    required this.onDelete,
  });

  final List<Trigger> triggers;
  final Future<void> Function(Trigger) onSave;
  final Future<void> Function(Trigger) onDelete;

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: const Text('Triggers'),
      save: onSave,
      items: storeOf(context).currentProfile.triggers,
      detailsPath: Paths.trigger,
      displayName: (trigger) => trigger.pattern,
      searchTags: (trigger) => [
        trigger.action.content,
        trigger.group,
      ],
      itemBuilder: (context, trigger) {
        return ListTile(
          key: Key(trigger.id),
          title: Text(trigger.pattern),
          subtitle: Text(trigger.action.content.replaceAll('\n', ' ')),
          leading: Switch.adaptive(
            value: trigger.enabled,
            onChanged: (value) {
              trigger.enabled = value;
              onSave(trigger);
            },
          ),
          isThreeLine: true,
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
                  onDelete(trigger);
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
              await onSave(updated as Trigger);
            }
          },
        );
      },
    );
  }
}

