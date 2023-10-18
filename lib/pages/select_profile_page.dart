import 'package:flutter/material.dart';

import '../core/features/profile.dart';
import '../core/routes.dart';
import '../core/store.dart';

class SelectProfilePage extends StatelessWidget with GameStoreMixin {
  const SelectProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile'),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: GameStore.consumer(
            builder: (context, store, child) => ListView(
              children: [
                for (final profile in store.profiles)
                  ListTile(
                    title: Text(profile.name),
                    subtitle: Text('${profile.host}:${profile.port}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ];
                      },
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updated = await Navigator.pushNamed(
                            context,
                            Paths.profile,
                            arguments: profile,
                          );
                          if (updated != null) {
                            await (updated as MUDProfile).save();
                            store.loadSavedProfiles();
                          }
                        } else if (value == 'delete') {
                          await profile.delete();
                          store.loadSavedProfiles();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context, profile);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final store = storeOf(context);
          final profile = await Navigator.pushNamed(
            context,
            Paths.profile,
          );
          if (profile != null) {
            await (profile as MUDProfile).save();
            store.loadSavedProfiles();
          }
        },
      ),
    );
  }
}

