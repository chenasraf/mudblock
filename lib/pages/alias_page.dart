import 'package:flutter/material.dart';

import '../core/features/action.dart';
import '../core/features/alias.dart';
import '../core/platform_utils.dart';

class AliasPage extends StatefulWidget {
  const AliasPage({super.key, required this.alias});

  final Alias? alias;

  @override
  State<AliasPage> createState() => _AliasPageState();
}

class _AliasPageState extends State<AliasPage> {
  late final Alias alias;

  @override
  void initState() {
    alias = widget.alias?.copyWith() ?? Alias.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alias'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 1200,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  final patternTextField = TextField(
                    controller: TextEditingController(text: alias.pattern),
                    decoration: const InputDecoration(
                      labelText: 'Pattern',
                      helperText: 'The pattern to match your input against',
                    ),
                    onChanged: (value) {
                      alias.pattern = value;
                    },
                  );
                  final regexCheckbox = CheckboxListTile(
                    title: const Text('Regular Expression'),
                    // subtitle: const Text(
                    //   'Whether the pattern is a regular expression',
                    // ),
                    value: alias.isRegex,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        alias.isRegex = value ?? false;
                      });
                    },
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (PlatformUtils.isDesktop)
                        Row(
                          children: [
                            Expanded(
                              child: patternTextField,
                            ),
                            SizedBox(
                              width: 270,
                              child: regexCheckbox,
                            ),
                          ],
                        ),
                      if (!PlatformUtils.isDesktop) ...[
                        patternTextField,
                        regexCheckbox,
                      ],
                      TextField(
                        controller:
                            TextEditingController(text: alias.action.content),
                        minLines: PlatformUtils.isDesktop ? 20 : 5,
                        maxLines: PlatformUtils.isDesktop ? 50 : 20,
                        decoration: const InputDecoration(
                          labelText: 'Action',
                        ),
                        onChanged: (value) {
                          alias.action.content = value;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          'Send To',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      DropdownMenu(
                        initialSelection: alias.action.sendTo,
                        onSelected: (value) {
                          if (value is MUDActionTarget) {
                            alias.action.sendTo = value;
                          }
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: MUDActionTarget.world,
                            label: 'World',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.execute,
                            label: 'Execute',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.script,
                            label: 'Script',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.input,
                            label: 'Command Input',
                          ),
                        ],
                      ),
                      CheckboxListTile(
                        title: const Text('Case Sensitive'),
                        subtitle: const Text(
                          'If checked, the pattern will only match if the case matches.',
                        ),
                        value: alias.isCaseSensitive,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            alias.isCaseSensitive = value ?? false;
                          });
                        },
                      ),
                      // CheckboxListTile(
                      //   title: const Text('Remove From Buffer'),
                      //   subtitle: const Text(
                      //     'If checked, the line will be removed from the buffer after it is matched.',
                      //   ),
                      //   value: alias.isRemovedFromBuffer,
                      //   controlAffinity: ListTileControlAffinity.leading,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       alias.isRemovedFromBuffer = value ?? false;
                      //     });
                      //   },
                      // ),
                      CheckboxListTile(
                        title: const Text('Temporary'),
                        subtitle: const Text(
                          'If checked, the alias will be disabled after it is matched.',
                        ),
                        value: alias.isTemporary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            alias.isTemporary = value ?? false;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, alias);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

