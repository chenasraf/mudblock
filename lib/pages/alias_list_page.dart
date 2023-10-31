import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/alias.dart';
import '../core/routes.dart';
import 'automation_list_page.dart';

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
    return AutomationListPage<Alias>(
      automations: aliases,
      onSave: onSave,
      onDelete: onDelete,
      detailsPagePath: Paths.alias,
      title: 'Aliases',
    );
  }
}

