import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/features/profile.dart';
import '../core/platform_utils.dart';
import '../core/routes.dart';
import '../core/store.dart';

class HomeScaffold extends StatelessWidget with GameStoreMixin {
  final Widget Function(BuildContext, Widget?) builder;

  const HomeScaffold({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mudblock'),
      ),
      body: ChangeNotifierProvider.value(
        value: gameStore,
        builder: builder,
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: PlatformUtils.isDesktop
              ? const EdgeInsets.only(top: 60)
              : EdgeInsets.zero,
          child: ListView(
            children: [
              ListTile(
                title: const Text('Aliases'),
                onTap: () => Navigator.pushNamed(context, Paths.aliases),
              ),
              ListTile(
                title: const Text('Triggers'),
                onTap: () => Navigator.pushNamed(context, Paths.triggers),
              ),
              ListTile(
                title: const Text('Variables'),
                onTap: () => Navigator.pushNamed(context, Paths.variables),
              ),
              ListTile(
                title: const Text('Profile'),
                onTap: () async {
                  final store = storeOf(context);
                  final updated = await Navigator.pushNamed(
                    context,
                    Paths.profile,
                    arguments: store.currentProfile,
                  );
                  if (updated != null) {
                    await MUDProfile.save(updated as MUDProfile);
                    store.loadProfiles();
                  }
                },
              ),
              ListTile(
                title: const Text('Settings'),
                onTap: () => Navigator.pushNamed(context, Paths.settings),
              ),
              ListTile(
                title: const Text('Disconnect'),
                onTap: () async {
                  await gameStore.disconnect();
                  if (context.mounted) {
                    gameStore.connect(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
