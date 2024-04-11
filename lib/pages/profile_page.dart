import 'package:flutter/material.dart';

import '../core/features/profile.dart';
import '../dialogs/confirmation_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.profile});

  final MUDProfile? profile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late MUDProfile profile;
  late bool isNew;
  bool dirty = false;
  final nameController = TextEditingController();

  @override
  void initState() {
    profile = widget.profile?.copyWith() ?? MUDProfile.empty();
    nameController.text = profile.name;
    isNew = widget.profile == null;
    super.initState();
  }

  void setDirty() {
    if (dirty) {
      return;
    }
    setState(() {
      dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillConfirmPopScope(
      dirty: dirty,
      child: Scaffold(
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Profile name',
                        helperText: 'The name of the profile',
                      ),
                      onChanged: (value) {
                        setDirty();
                        profile.name = value;
                        if (isNew) {
                          profile = profile.copyWith(
                            id: value.replaceAll(RegExp(r'\W+'), '_'),
                          );
                        }
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: profile.host),
                      decoration: const InputDecoration(
                        labelText: 'Host',
                      ),
                      onChanged: (value) {
                        setDirty();
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
                        setDirty();
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
                        setDirty();
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
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: DropdownMenu(
                        label: const Text('Authentication Method'),
                        initialSelection: profile.authMethod,
                        onSelected: (value) {
                          setDirty();
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
                    ),
                    TextField(
                      controller: TextEditingController(text: profile.username),
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      onChanged: (value) {
                        setDirty();
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
                        setDirty();
                        profile.password = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile.adaptive(
                      value: profile.authPostSend,
                      title:
                          const Text('Send an empty command after logging in'),
                      subtitle: const Text(
                          'Useful for servers that have an MOTD or require login confirmation.'),
                      onChanged: (value) {
                        setDirty();
                        setState(() {
                          profile.authPostSend = value ?? false;
                        });
                      },
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
      ),
    );
  }
}

