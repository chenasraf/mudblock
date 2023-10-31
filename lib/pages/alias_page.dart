import 'package:flutter/material.dart';

import '../core/features/alias.dart';
import 'automation_page.dart';

class AliasPage extends StatelessWidget {
  const AliasPage({
    super.key,
    this.alias,
    required this.onSave,
  });

  final Alias? alias;
  final void Function(Alias) onSave;

  @override
  Widget build(BuildContext context) {
    return AutomationPage<Alias>(
      automation: alias,
      title: 'Alias',
      onSave: onSave,
      create: (alias) => alias?.copyWith() ?? Alias.empty(),
    );
  }
}
