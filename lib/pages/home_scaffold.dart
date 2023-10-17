import 'package:flutter/material.dart';
import 'package:mudblock/core/features/game_button_set.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/features/alias.dart';
import '../core/features/profile.dart';
import '../core/features/trigger.dart';
import '../core/features/variable.dart';
import '../core/platform_utils.dart';
import '../core/routes.dart';
import '../core/store.dart';

class HomeScaffold extends StatelessWidget with GameStoreMixin {
  final Widget Function(BuildContext, Widget?) builder;

  const HomeScaffold({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final interaction = PlatformUtils.isDesktop ? 'Click' : 'Tap';
    return Scaffold(
      appBar: AppBar(
        title: GameStore.consumer(
          builder: (context, store, child) => Text(store.connected
              ? '${store.currentProfile.name} - Mudblock'
              : 'Mudblock'),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: gameStore,
        builder: builder,
      ),
      endDrawer: Drawer(
        child: GameStore.consumer(
          builder: (context, store, child) => ListView(
            children: [
              ListTile(
                leading: const Image(
                  image: AssetImage('assets/images/logo/logo.png'),
                  width: 32,
                  height: 32,
                ),
                title: const Text('Mudblock'),
                subtitle: FutureBuilder<String>(
                  future: PackageInfo.fromPlatform().then((pkg) => pkg.version),
                  builder: (context, data) {
                    final version = data.data ?? '...';
                    return Text('v$version');
                  },
                ),
                onTap: () => Navigator.pushNamed(context, Paths.about),
              ),
              const Divider(),
              ListTile(
                title: store.connected
                    ? Text(store.currentProfile.name)
                    : const Text('Not connected'),
                subtitle: store.connected
                    ? Text(
                        '${store.currentProfile.host}:${store.currentProfile.port}',
                      )
                    : Text('$interaction to connect'),
                leading: const CircleAvatar(child: Icon(Icons.cable)),
                onTap: store.connected
                    ? () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          Paths.profile,
                          arguments: store.currentProfile,
                        );
                        if (updated != null) {
                          await (updated as MUDProfile).save();
                          store.loadProfiles();
                        }
                      }
                    : () {
                        store.selectProfileAndConnect(context);
                      },
              ),
              if (store.connected) ...[
                ListTile(
                  title: const Text('Button Sets'),
                  leading: const Icon(GameButtonSetData.iconData),
                  onTap: () => Navigator.pushNamed(context, Paths.buttons),
                ),
                ListTile(
                  title: const Text('Aliases'),
                  leading: const Icon(Alias.iconData),
                  onTap: () => Navigator.pushNamed(context, Paths.aliases),
                ),
                ListTile(
                  title: const Text('Triggers'),
                  leading: const Icon(Trigger.iconData),
                  onTap: () => Navigator.pushNamed(context, Paths.triggers),
                ),
                ListTile(
                  title: const Text('Variables'),
                  leading: const Icon(Variable.iconData),
                  onTap: () => Navigator.pushNamed(context, Paths.variables),
                ),
                if (PlatformUtils.isDesktop)
                  ListTile(
                    title: const Text('Keyboard Shortcuts'),
                    leading: const Icon(Icons.keyboard),
                    onTap: () => Navigator.pushNamed(context, Paths.shortcuts),
                  ),
                const Divider(),
                ListTile(
                  title: const Text('Settings'),
                  leading: const Icon(Icons.settings),
                  onTap: () => Navigator.pushNamed(context, Paths.settings),
                ),
                ListTile(
                  title: const Text('Disconnect'),
                  leading: const Icon(Icons.exit_to_app),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await gameStore.disconnect();
                    if (context.mounted) {
                      gameStore.selectProfileAndConnect(context);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

