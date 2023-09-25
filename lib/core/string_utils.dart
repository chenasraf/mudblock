import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String uuid() {
  return _uuid.v4();
}

