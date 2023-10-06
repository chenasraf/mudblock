import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String uuid() {
  return _uuid.v4();
}

/// split by any non-word character, or by camelCase/PascalCase
List<String> splitIntoWords(String string) {
  return string
      .split(RegExp(r'[\W_]+|(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'));
}

String capitalize(String string) {
  return splitIntoWords(string)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

