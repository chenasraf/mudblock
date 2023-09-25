import 'package:flutter/material.dart';
import 'package:mudblock/core/profile_presets.dart';

class ProfileSelectPage extends StatelessWidget {
  const ProfileSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile'),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        for (final profile in profilePresets)
          ListTile(
            title: Text(profile.name),
            subtitle: Text('${profile.host}:${profile.port}'),
            onTap: () {
              Navigator.pop(context, profile);
            },
          ),
      ])),
    );
  }
}

