import 'package:flutter/material.dart';

import '../core/features/trigger.dart';
import 'automation_page.dart';

class TriggerPage extends StatelessWidget {
  const TriggerPage({
    super.key,
    this.trigger,
    required this.onSave,
  });

  final Trigger? trigger;
  final void Function(Trigger) onSave;

  @override
  Widget build(BuildContext context) {
    return AutomationPage<Trigger>(
      automation: trigger,
      title: 'Trigger',
      onSave: onSave,
      create: (trigger) => trigger?.copyWith() ?? Trigger.empty(),
    );
  }
}

