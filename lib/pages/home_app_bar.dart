import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GameStore.consumer(
        builder: (context, store, child) => Text(store.connected
            ? '${store.currentProfile.name} - Mudblock'
            : 'Mudblock'),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

