import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/variable.dart';
import '../core/routes.dart';

class VariableListPage extends StatelessWidget with GameStoreMixin {
  const VariableListPage({
    super.key,
    required this.variables,
    required this.onSave,
  });

  final List<Variable> variables;
  final Future<void> Function(Variable variable) onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variables'),
      ),
      body: ListView.builder(
        itemCount: variables.length,
        itemBuilder: (context, item) {
          final variable = variables.elementAt(item);
          return ListTile(
            key: Key(variable.name),
            title: Text(variable.name),
            subtitle: Text(variable.value),
            onTap: () async {
              final updated = await Navigator.pushNamed(
                context,
                Paths.variable,
                arguments: variable,
              );
              if (updated != null) {
                await onSave(updated as Variable);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final variable = await Navigator.pushNamed(context, Paths.variable);
          if (variable != null) {
            onSave(variable as Variable);
          }
        },
      ),
    );
  }
}

