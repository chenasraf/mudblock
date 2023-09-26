import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/store.dart';

class MainScaffold extends StatelessWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const MainScaffold({super.key, required this.builder});

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
        child: ListView(
          children: [
            ListTile(
              title: const Text('Aliases'),
              onTap: () {
                Navigator.pushNamed(context, '/aliases');
              },
            ),
            ListTile(
              title: const Text('Triggers'),
              onTap: () {
                Navigator.pushNamed(context, '/triggers');
              },
            ),
            ListTile(
              title: const Text('Disconnect'),
              onTap: () {
                gameStore.connect();
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

