import 'package:flutter/material.dart';
import 'package:mudblock/core/features/alias.dart';
import 'package:mudblock/core/features/game_button_set.dart';
import 'package:mudblock/core/features/profile.dart';
import 'package:mudblock/core/features/trigger.dart';
import 'package:mudblock/core/features/variable.dart';
import 'package:mudblock/core/platform_utils.dart';
import 'package:mudblock/core/routes.dart';
import 'package:mudblock/core/store.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final interaction = PlatformUtils.isDesktop ? 'Click' : 'Tap';
    return Drawer(
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
                        store.loadSavedProfiles();
                      }
                    }
                  : () {
                      store.selectProfileAndConnect(context);
                    },
            ),
            if (store.connected) ...[
              _tile(context, GameButtonSetData.iconData, 'Button Sets',
                  route: Paths.buttons),
              _tile(context, Alias.iconData, 'Aliases', route: Paths.aliases),
              _tile(context, Trigger.iconData, 'Triggers',
                  route: Paths.triggers),
              _tile(context, Variable.iconData, 'Variables',
                  route: Paths.variables),
              if (PlatformUtils.isDesktop)
                _tile(context, Icons.keyboard, 'Keyboard Shortcuts',
                    route: Paths.shortcuts),
              const Divider(),
              _tile(context, Icons.cable, 'Profiles', route: Paths.profiles),
              _tile(context, Icons.settings, 'Settings', route: Paths.settings),
              _tile(
                context,
                Icons.exit_to_app,
                'Disconnect',
                onTap: () async {
                  Navigator.of(context).pop();
                  await gameStore.disconnect();
                  if (context.mounted) {
                    gameStore.selectProfileAndConnect(context);
                  }
                },
              ),
            ],
            if (!store.connected)
              ListTile(
                title: const Text('Settings'),
                leading: const Icon(Icons.settings),
                onTap: () => Navigator.pushNamed(context, Paths.settings),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title, {
    String? route,
    void Function()? onTap,
  }) {
    assert(route != null || onTap != null);
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap ?? () => Navigator.pushNamed(context, route!),
    );
  }
}

