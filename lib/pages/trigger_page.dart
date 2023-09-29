import 'package:flutter/material.dart';

import '../core/features/action.dart';
import '../core/features/trigger.dart';
import '../core/platform_utils.dart';

class TriggerPage extends StatefulWidget {
  const TriggerPage({super.key, required this.trigger});

  final Trigger? trigger;

  @override
  State<TriggerPage> createState() => _TriggerPageState();
}

class _TriggerPageState extends State<TriggerPage> {
  late final Trigger trigger;

  @override
  void initState() {
    trigger = widget.trigger?.copyWith() ?? Trigger.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigger'),
        actions: [
          Switch.adaptive(
            value: trigger.enabled,
            onChanged: (value) {
              trigger.enabled = value;
            },
          )
        ],
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
                    controller: TextEditingController(text: trigger.pattern),
                    decoration: const InputDecoration(
                      labelText: 'Pattern',
                      helperText: 'The pattern to match your input against',
                    ),
                    onChanged: (value) {
                      trigger.pattern = value;
                    },
                  );
                  final regexCheckbox = CheckboxListTile(
                    title: const Text('Regular Expression'),
                    // subtitle: const Text(
                    //   'Whether the pattern is a regular expression',
                    // ),
                    value: trigger.isRegex,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        trigger.isRegex = value ?? false;
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
                            TextEditingController(text: trigger.action.content),
                        minLines: PlatformUtils.isDesktop ? 20 : 5,
                        maxLines: PlatformUtils.isDesktop ? 50 : 20,
                        decoration: const InputDecoration(
                          labelText: 'Action',
                        ),
                        onChanged: (value) {
                          trigger.action.content = value;
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
                        initialSelection: trigger.action.sendTo,
                        onSelected: (value) {
                          if (value is MUDActionTarget) {
                            trigger.action.sendTo = value;
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
                        value: trigger.isCaseSensitive,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            trigger.isCaseSensitive = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Remove From Output'),
                        subtitle: const Text(
                          'If checked, the output line will be removed from the buffer when it is matched.',
                        ),
                        value: trigger.isRemovedFromBuffer,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            trigger.isRemovedFromBuffer = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Auto Disable'),
                        subtitle: const Text(
                          'If checked, the trigger will be disabled after it is matched once.',
                        ),
                        value: trigger.autoDisable,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            trigger.autoDisable = value ?? false;
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
          Navigator.pop(context, trigger);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

