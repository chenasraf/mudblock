import 'package:flutter/material.dart';

import '../core/features/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.profile});

  final MUDProfile? profile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final MUDProfile profile;

  @override
  void initState() {
    profile = widget.profile?.copyWith() ?? MUDProfile.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 1200,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: profile.name),
                    decoration: const InputDecoration(
                      labelText: 'Profile name',
                      helperText: 'The name of the profile',
                    ),
                    onChanged: (value) {
                      profile.name = value;
                    },
                  ),
                  TextField(
                    controller: TextEditingController(text: profile.host),
                    decoration: const InputDecoration(
                      labelText: 'Host',
                    ),
                    onChanged: (value) {
                      profile.host = value;
                    },
                  ),
                  TextField(
                    controller:
                        TextEditingController(text: profile.port.toString()),
                    decoration: const InputDecoration(
                      labelText: 'Port',
                    ),
                    onChanged: (value) {
                      profile.port = int.tryParse(value) ?? profile.port;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Enable MCCP Compression'),
                    subtitle: const Text(
                      'Enables MCCP Compression for this profile (if available).',
                    ),
                    value: profile.mccpEnabled,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        profile.mccpEnabled = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Authentication',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextField(
                    controller: TextEditingController(text: profile.username),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                    onChanged: (value) {
                      profile.username = value;
                    },
                  ),
                  TextField(
                    controller: TextEditingController(text: profile.password),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    onChanged: (value) {
                      profile.password = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  DropdownMenu(
                    label: const Text('Authentication Method'),
                    initialSelection: profile.authMethod,
                    onSelected: (value) {
                      setState(() {
                        profile.authMethod = value as AuthMethod;
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: AuthMethod.none,
                        label: 'None',
                      ),
                      DropdownMenuEntry(
                        value: AuthMethod.diku,
                        label: 'Diku-style',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, profile);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
