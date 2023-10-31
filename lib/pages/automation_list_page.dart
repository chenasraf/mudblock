import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/automation.dart';
import 'generic_list_page.dart';

class AutomationListPage<T extends Automation> extends StatelessWidget
    with GameStoreMixin {
  const AutomationListPage({
    super.key,
    required this.automations,
    required this.onSave,
    required this.onDelete,
    required this.detailsPagePath,
    required this.title,
  });

  final List<T> automations;
  final Future<void> Function(T) onSave;
  final Future<void> Function(T) onDelete;
  final String detailsPagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GenericListPage(
      title: Text(title),
      save: onSave,
      items: automations,
      detailsPath: detailsPagePath,
      displayName: (automation) => automation.displayName,
      searchTags: (automation) => [
        automation.action.content,
        automation.group,
      ],
      itemBuilder: (context, automation) {
        return ListTile(
          key: Key(automation.id),
          title: Text(automation.displayName),
          subtitle: Text(automation.action.content.replaceAll('\n', '↵')),
          leading: Switch.adaptive(
            value: automation.enabled,
            onChanged: (value) {
              automation.enabled = value;
              onSave(automation);
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
                  onDelete(automation);
                  break;
              }
            },
          ),
          onTap: () async {
            final updated = await Navigator.pushNamed(
              context,
              detailsPagePath,
              arguments: automation,
            );
            if (updated != null) {
              await onSave(updated as T);
            }
          },
        );
      },
    );
  }
}

