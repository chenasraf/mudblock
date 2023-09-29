import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

import '../core/features/variable.dart';
import '../core/routes.dart';

class VariableListPage extends StatelessWidget with GameStoreMixin {
  const VariableListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variables'),
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          debugPrint('Variable list rebuild');
          final variables = store.variables.values;
          return ListView.builder(
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
                    await save(store, updated as Variable);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final store = storeOf(context);
          final variable = await Navigator.pushNamed(context, Paths.variable);
          if (variable != null) {
            save(store, variable as Variable);
          }
        },
      ),
    );
  }

  Future<void> save(GameStore store, Variable updated) async {
    await store.currentProfile
        .saveVariable(store.variables.values.toList(), updated);
    await store.loadVariables();
  }
}
