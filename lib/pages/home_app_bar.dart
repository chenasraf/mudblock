import 'package:flutter/material.dart';
import 'package:mudblock/core/features/alias.dart';
import 'package:mudblock/core/features/game_button_set.dart';
import 'package:mudblock/core/features/trigger.dart';
import 'package:mudblock/core/features/variable.dart';
import 'package:mudblock/core/platform_utils.dart';
import 'package:mudblock/core/routes.dart';
import 'package:mudblock/core/store.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameStore.consumer(
      builder: (context, store, child) => AppBar(
        title: _title(store),
        centerTitle: false,
        // centerTitle: !PlatformUtils.isDesktop,
        actions: [
          if (MediaQuery.of(context).size.width > 600)
            ..._actions(context, store),
          _button(
            context,
            Icons.menu,
            'Open Drawer',
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _title(GameStore store) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 26,
          child: Image.asset('assets/images/logo/logo.png'),
        ),
        const SizedBox(width: 12),
        Text(
          store.connected
              ? '${store.currentProfile.name} - Mudblock'
              : 'Mudblock',
          textScaler:
              TextScaler.linear(store.globalSettings.uiTextScale * 0.85),
        ),
      ],
    );
  }

  List<Widget> _actions(BuildContext context, GameStore store) {
    if (!store.connected) {
      return [
        _button(
          context,
          Icons.cable,
          'Connect',
          onPressed: () => store.selectProfileAndConnect(context),
        ),
        _button(context, Icons.settings, 'Settings', route: Paths.settings),
      ];
    }
    return [
      _button(context, GameButtonSetData.iconData, 'Button Sets',
          route: Paths.buttons),
      _button(context, Alias.iconData, 'Aliases', route: Paths.aliases),
      _button(context, Trigger.iconData, 'Triggers', route: Paths.triggers),
      _button(context, Variable.iconData, 'Variables', route: Paths.variables),
      if (PlatformUtils.isDesktop)
        _button(context, Icons.keyboard, 'Keyboard Shortcuts',
            route: Paths.shortcuts),
      // const Divider(),
      // _button(context, Icons.cable, 'Profiles', route: Paths.profiles),
      _button(context, Icons.settings, 'Settings', route: Paths.settings),
    ];
  }

  Widget _button(
    BuildContext context,
    IconData icon,
    String text, {
    String? route,
    void Function()? onPressed,
  }) {
    assert(route != null || onPressed != null);
    return IconButton(
      tooltip: text,
      icon: Icon(icon),
      onPressed: onPressed ?? () => Navigator.pushNamed(context, route!),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

