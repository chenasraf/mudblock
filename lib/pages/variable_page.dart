import 'package:flutter/material.dart';

import '../core/features/variable.dart';

class VariablePage extends StatefulWidget {
  const VariablePage({super.key, required this.variable});

  final Variable? variable;

  @override
  State<VariablePage> createState() => _VariablePageState();
}

class _VariablePageState extends State<VariablePage> {
  late final Variable variable;

  @override
  void initState() {
    variable = widget.variable?.copyWith() ?? Variable.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variable'),
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: TextEditingController(text: variable.name),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          helperText: 'The name of the variable',
                        ),
                        onChanged: (value) {
                          variable.name = value;
                        },
                      ),
                      TextField(
                        controller: TextEditingController(text: variable.value),
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          helperText: 'The value of the variable',
                        ),
                        onChanged: (value) {
                          variable.value = value;
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
          Navigator.pop(context, variable);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
