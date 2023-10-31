import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/trigger.dart';
import '../core/routes.dart';
import 'automation_list_page.dart';

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
    return AutomationListPage<Trigger>(
      automations: triggers,
      onSave: onSave,
      onDelete: onDelete,
      detailsPagePath: Paths.trigger,
      title: 'Triggers',
    );
  }
}

