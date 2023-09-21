import 'interfaces.dart';

class StringReader implements IReader<String> {
  final String input;

  @override
  int index = 0;

  StringReader(this.input);

  @override
  int get length => input.length;

  @override
  bool get isDone => index >= length;

  @override
  String? peek() {
    if (isDone) {
      return null;
    }
    return input[index];
  }

  @override
  String? read() {
  if (isDone) {
    return null;
    }
    return input[index++];
  }
}

