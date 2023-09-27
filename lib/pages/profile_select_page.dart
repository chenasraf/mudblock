import 'package:flutter/material.dart';
import 'package:mudblock/core/profile_presets.dart';

class ProfileSelectPage extends StatelessWidget {
  const ProfileSelectPage({super.key});

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
                child: Column(
                  children: [
                    for (final profile in profilePresets)
                      ListTile(
                        title: Text(profile.name),
                        subtitle: Text('${profile.host}:${profile.port}'),
                        onTap: () {
                          Navigator.pop(context, profile);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

