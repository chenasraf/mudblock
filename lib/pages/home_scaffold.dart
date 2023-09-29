import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/platform_utils.dart';
import '../core/routes.dart';
import '../core/store.dart';

class HomeScaffold extends StatelessWidget {
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

