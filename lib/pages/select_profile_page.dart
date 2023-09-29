import 'package:flutter/material.dart';

import '../core/features/profile.dart';
import '../core/routes.dart';
import '../core/store.dart';

class SelectProfilePage extends StatelessWidget with GameStoreMixin {
  const SelectProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        child: SizedBox(
          width: 800,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select Profile',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SingleChildScrollView(
                child: GameStore.consumer(
                  builder: (context, store, child) => Column(
                    children: [
                      for (final profile in store.profiles)
                        ListTile(
                          title: Text(profile.name),
                          subtitle: Text('${profile.host}:${profile.port}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final store = storeOf(context);
                                  final updated = await Navigator.pushNamed(
                                    context,
                                    Paths.profile,
                                    arguments: profile,
                                  );
                                  if (updated != null) {
                                    await MUDProfile.save(
                                        updated as MUDProfile);
                                    store.loadProfiles();
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context, profile);
                          },
                        ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
