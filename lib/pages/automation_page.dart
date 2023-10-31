import 'package:flutter/material.dart';

import '../core/features/action.dart';
import '../core/features/alias.dart';
import '../core/features/automation.dart';
import '../core/platform_utils.dart';

class AutomationPage<T extends Automation> extends StatefulWidget {
  const AutomationPage({
    super.key,
    required this.automation,
    required this.create,
    required this.title,
    required this.onSave,
  });

  final T? automation;
  final T Function(T? automation) create;
  final void Function(T automation) onSave;
  final String title;

  @override
  State<AutomationPage> createState() => _AutomationPageState<T>();
}

class _AutomationPageState<T extends Automation>
    extends State<AutomationPage<T>> {
  late final T automation;
  final variableTargetController = TextEditingController();

  @override
  void initState() {
    automation = widget.create(widget.automation);
    variableTargetController.text =
        automation.action.args.isNotEmpty ? automation.action.args.single : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Switch.adaptive(
            value: automation.enabled,
            onChanged: (value) async {
              automation.enabled = value;
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
                  var automationMatcheeStr =
                      T == Alias ? 'your input' : 'the output';
                  var automationTypeStr = T == Alias ? 'alias' : 'trigger';
                  final patternTextField = TextField(
                    controller: TextEditingController(text: automation.pattern),
                    decoration: InputDecoration(
                      labelText: 'Pattern',
                      helperText:
                          'The pattern to match $automationMatcheeStr against',
                    ),
                    onChanged: (value) {
                      automation.pattern = value;
                    },
                  );
                  final regexCheckbox = CheckboxListTile(
                    title: const Text('Regular Expression'),
                    // subtitle: const Text(
                    //   'Whether the pattern is a regular expression',
                    // ),
                    value: automation.isRegex,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        automation.isRegex = value ?? false;
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
                            TextEditingController(text: automation.label),
                        decoration: InputDecoration(
                          labelText: 'Label',
                          helperText:
                              'Can be used to identify the $automationTypeStr in scripts',
                        ),
                        onChanged: (value) {
                          automation.label = value;
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                          text: automation.action.content,
                        ),
                        minLines: PlatformUtils.isDesktop ? 20 : 5,
                        maxLines: PlatformUtils.isDesktop ? 50 : 20,
                        decoration: const InputDecoration(
                          labelText: 'Action',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (value) {
                          automation.action.content = value;
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
                        initialSelection: automation.action.target,
                        onSelected: (value) {
                          if (value is MUDActionTarget) {
                            setState(() {
                              automation.action.target = value;
                            });
                          }
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: MUDActionTarget.execute,
                            label: 'Execute',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.script,
                            label: 'Script',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.variable,
                            label: 'Variable',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.world,
                            label: 'World',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.input,
                            label: 'Command Input',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.immediate,
                            label: 'Immediate',
                          ),
                          DropdownMenuEntry(
                            value: MUDActionTarget.output,
                            label: 'Output',
                          ),
                        ],
                      ),
                      if (automation.action.target == MUDActionTarget.variable)
                        TextField(
                          controller: variableTargetController,
                          decoration: const InputDecoration(
                            labelText: 'Variable name',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            helperText: 'The name of the variable to set',
                          ),
                          onChanged: (value) {
                            automation.action.args = [value];
                          },
                        ),
                      CheckboxListTile(
                        title: const Text('Case Sensitive'),
                        subtitle: const Text(
                          'If checked, the pattern will only match if the case matches.',
                        ),
                        value: automation.isCaseSensitive,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            automation.isCaseSensitive = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Remove From Output'),
                        subtitle: Text(
                          'If checked, $automationMatcheeStr line will be removed from the buffer when it is matched.',
                        ),
                        value: automation.isRemovedFromBuffer,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            automation.isRemovedFromBuffer = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Auto Disable'),
                        subtitle: Text(
                          'If checked, the $automationTypeStr will be disabled after it is matched once.',
                        ),
                        value: automation.autoDisable,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            automation.autoDisable = value ?? false;
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
          Navigator.pop(context, automation);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

