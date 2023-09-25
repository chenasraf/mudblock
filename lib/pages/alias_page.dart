import 'package:flutter/material.dart';

import '../core/features/alias.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: alias.pattern),
                      decoration: const InputDecoration(
                        labelText: 'Pattern',
                      ),
                      onChanged: (value) {
                          alias.pattern = value;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: const Text('Regular Expression'),
                      value: alias.isRegex,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                          alias.isRegex = value ?? false;
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: TextEditingController(text: alias.action.content),
                decoration: const InputDecoration(
                  labelText: 'Action',
                ),
                onChanged: (value) {
                    alias.action.content = value;
                },
              ),
            ],
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

